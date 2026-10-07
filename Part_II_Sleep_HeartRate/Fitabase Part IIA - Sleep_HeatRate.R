# install.packages("ivs")

library(tidyverse)
library(lubridate) # 處理日期與時間的強大套件
library(ivs) # 專門用於處理與操作「區間向量（Interval Vectors）」的核心工具:所有區間皆為「左閉右開」

# Read data 
sleep_data <- read.csv("Desktop/Fitabase Data/Fitabase Data 4.12.16-5.12.16/minuteSleep_merged.csv")
heart_rate_data <- read.csv("Desktop/Fitabase Data/Fitabase Data 4.12.16-5.12.16/heartrate_seconds_merged.csv")

# Process data

## A - 睡眠資料整合(單位：minute) --------------------------------------
### Value column: 1 - Asleep, 2 - Restless, 3 - Awake
### LogId: 系統自動生成的一串長整數流水號，用來標記「單次完整的睡眠事件（Sleep Session）」
sleep_summary <- sleep_data |> 
  # 將 date 欄位轉換成真正的時間格式
  mutate(date = mdy_hms(date)) |> 
  arrange(logId, Id, date) |> 
  group_by(logId, Id) |> 
  summarise(
    bed_start = min(date), 
    bed_end = max(date),
    
    # 在床上的時間: logId 相同的總時數
    total_bed_min = n(),
    
    # 實際入睡時間（當天第一次 value ==1 的時間）
    sleep_start = date[value == 1][1],
    
    # 是否入睡困難（sleep latency）
    ## difftime() 預設會回傳帶有單位的特殊物件。需要用 as.numeric() 把它變成單純的數字
    sleep_latency = as.numeric(difftime(sleep_start, bed_start, units = "mins")),
    
    # 總睡眠時間: value == 1
    total_sleep_min = sum(value==1),
    
    # 中斷睡眠（清醒）次數（value狀態切換）
    ## lag(x)：取得前一個的值, lead(x)：取得後一個的值
    ### 半夜躁動/翻身次數 (1 --> 2)
    awake_counts = sum(value == 1 & lead(value) == 3, na.rm = TRUE),
    ### 半夜真正清醒次數 (1 --> 3)
    restless_counts = sum(value == 1 & lead(value) == 2, na.rm = TRUE),
    
    # 區分晚上睡眠和午休小睡
    sleep_type = if_else(total_bed_min >= 180, "Main Sleep", "Nap"),
    
    # 當您使用 group_by 將資料分組後進行計算，R 會記住這個分組。這可能會影響您後續的分析。加上 .groups = drop，可以讓計算後的結果恢復成一般的表格
    .groups = "drop"
  )

## B - 心率資料整合(單位：5 seconds) --------------------------------------

### 在整理心率資料前，要先把一些特殊時間抓出來，才能利用對應的時間去做心率資料分析
# 1 - 整段睡眠時間：sleep_start ~ bed_end
# 2 - 半夜 Awake/Restless 的區間

#### 建立「時間區間(interval)」欄位
sleep_intervals <- sleep_summary |> 
  # 先抓出晚上睡眠的資料
  filter(sleep_type == "Main Sleep") |> 
  mutate(
    # 整段睡眠時間：sleep_start ~ bed_end
    sleep_range = iv(sleep_start, bed_end),
    
    # 清晨靜心心率 Resting Heart Rate, RHR 區間
    morning_rhr_range = iv(bed_end - minutes(45), bed_end - minutes(15)),
    
    # 起床 Arousal HR 區間
    arousal_hr_range = iv(bed_end, bed_end + minutes(3))
  )

#### 提取半夜 awake/restless 的時間區間:將連續相同的睡眠狀態群組化
sleep_event_intervals <- sleep_data |> 
  # 將 date 欄位轉換成真正的時間格式
  mutate(date = mdy_hms(date)) |> 
  arrange(logId, Id, date) |> 
  
  # 找出狀態連續不變的區段 (Group by consecutive state)
  group_by(logId, Id) |> 
  mutate(state_group = consecutive_id(value)) |> 
  
  # 依據每個狀態區段進行小聚合
  group_by(logId, Id, state_group, value) |> 
  summarise(
    event_start = min(date),
    event_end = max(date) + minutes(1), # 因為是分鐘資料，結束時間加上 1 分鐘形成完整區間
    .groups = "drop"
  ) |> 
  
  # 建立 ivs 區間
  mutate(event_interval = iv(event_start, event_end)) 

# ==========================================
### 可以合併心率資料並計算了～
## -- hr_main_summary --
# 1 - 整體睡眠心率 (avg_sleep_hr)
# 2 - 清晨穩定靜息心率 (morning_rhr)
# 3 - 起床時Arousal心率(arousal_hr)
## -- hr_event_summary --
# 4 - 半夜 Awake 期間的心率 (avg_awake_hr, max_awake_hr)
# 5 - 半夜 Restless 期間的心率 (avg_restless_hr)

hr_main_summary <- heart_rate_data |> 
  # 確保心率時間為 POSIXct 格式
  mutate(Time = mdy_hms(Time)) |> 
  
  # 連接資料：先用"Id"連接，此時會包含很多天的資料
  inner_join(sleep_intervals, by = "Id", relationship = "many-to-many") |> 

  # 過濾：只留下心率時間確實落在「整段睡眠區間」的資料!!
  # iv_between(needles 要被檢查的目標向量, haystack 區間向量, missing = "equals")
  filter(iv_between(needles = Time, haystack = sleep_range)) |> 
  
  group_by(Id, logId) |> 
  summarise(
    # 1 - 整體睡眠心率 (avg_sleep_hr)
    avg_sleep_hr = mean(Value[iv_between(needles = Time, haystack = sleep_range)], na.rm = TRUE),
    max_sleep_hr = max(Value[iv_between(needles = Time, haystack = sleep_range)], na.rm = TRUE),
    min_sleep_hr = min(Value[iv_between(needles = Time, haystack = sleep_range)], na.rm = TRUE),
    
    # 2 - 清晨穩定靜息心率 (morning_rhr) - bed_end前45~15分鐘
    morning_rhr = mean(Value[iv_between(needles = Time, haystack = morning_rhr_range)]),
    
    # 3 - 起床時Arousal心率(arousal_hr) - bed_end一分鐘內
    avg_arousal_hr = mean(Value[iv_between(needles = Time, haystack = arousal_hr_range)]),

    .groups = "drop"
  )

## 試跑一次後，記憶體炸裂
## 給心率表和事件表都加上一個 date（年月日）欄位，讓 join 時同時比對 Id 與 date
sleep_event_intervals_clean <- sleep_event_intervals |> 
  # 只篩選 value 為 2 或 3 的事件區間來做 join
  filter(value %in% c(2,3)) |> 
  mutate(event_date = as_date(event_start)) # 提取年月日
           
hr_event_summary <- heart_rate_data |> 
  mutate(Time = mdy_hms(Time),
         hr_date = as_date(Time)  # 提取年月日
         ) |> 
  inner_join(sleep_event_intervals_clean, 
             by = c("Id" = "Id", "hr_date" = "event_date"), 
             relationship = "many-to-many") |> 
  filter(iv_between(needles = Time, haystack = event_interval)) |> 
  group_by(Id, logId) |> 
  summarise(
    # 4 - 半夜 Awake 期間的心率 (avg_awake_hr, max_awake_hr)
    avg_awake_hr = mean(Value[value == 3], na.rm = TRUE),
    max_awake_hr = ifelse(any(value == 3), max(Value[value == 3], na.rm = TRUE), NA),
    
    # 5 - 半夜 Restless 期間的心率 (avg_restless_hr)
    avg_restless_hr = mean(Value[value == 2], na.rm = TRUE),
    
    .groups = "drop"
  )

# 合併成大資料表
hr_summary_final <- hr_main_summary |> 
  left_join(hr_event_summary, 
            by = c("Id", "logId"))
