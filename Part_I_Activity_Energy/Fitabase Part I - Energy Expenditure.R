#install.packages("tidyverse")
#install.packages("ggpmisc")
#install.packages("ggExtra")
#install.packages("patchwork")

# The library() function is used to load and attach installed add-on packages to your current R session
library(lubridate)
library(ggpmisc)
library(tidyverse)
library(ggExtra)
library(patchwork)

# 1 - Read "hourly" Data and summary
hourly_steps <- read.csv("Desktop/Fitabase Data/Fitabase Data 4.12.16-5.12.16/hourlySteps_merged.csv")
glimpse(hourly_steps)

hourly_calories <- read.csv("Desktop/Fitabase Data/Fitabase Data 4.12.16-5.12.16/hourlyCalories_merged.csv")
glimpse(hourly_calories)

hourly_intensities <- read.csv("Desktop/Fitabase Data/Fitabase Data 4.12.16-5.12.16/hourlyIntensities_merged.csv")
glimpse(hourly_intensities)

# 2 - 把 ActivityHour 從字串轉換成 R 看得懂的時間格式，方便之後篩選
# mutate() 專門用於新增衍生變數或修改現有變數，同時會保留資料框中所有原始欄位
# mdy_hms 是 lubridate 套件中常用的函數，用於將文字字串轉換為具體的日期與時間（POSIXct）格式。字面代表「月Month、日Day、年Year - 時Hour、分Minute、秒Second」
# head(hourly_steps)
hourly_steps <- hourly_steps |> 
  mutate(ActivityHour = mdy_hms(ActivityHour))
# head(hourly_steps)

# head(hourly_intensities)
hourly_intensities <- hourly_intensities |> 
  mutate(ActivityHour = mdy_hms(ActivityHour))
# head(hourly_intensities)

# head(hourly_calories)
hourly_calories <- hourly_calories |> 
  mutate(ActivityHour = mdy_hms(ActivityHour))
# head(hourly_calories)

# 3 - Using "left_join" to connect 3 forms
hourly_merged <- hourly_steps |> 
  left_join(hourly_calories, by = c("Id", "ActivityHour")) |> 
  left_join(hourly_intensities, by = c("Id", "ActivityHour"))

glimpse(hourly_merged)
head(hourly_merged)

## -------------------------------------------------
# A - 群體趨勢
hourly_trend <- hourly_merged |> 
  mutate(Hour = hour(ActivityHour)) |>  # 抓出“hour”：我們只在乎“時”，日期就是干擾因子
  group_by(Hour) |> 
  summarise(avg_steps = mean(StepTotal),
            avg_colories = mean(Calories))
head(hourly_trend)

# Barplot 
ggplot(data = hourly_trend, aes(x = Hour, y = avg_steps)) +
  geom_col(fill = "steelblue")+
  scale_x_continuous(limits = c(-0.5, 23.5),  # 讓 0 和 24 的直條不會被切到邊緣
                     breaks = seq(0, 23, by = 2),  # 每2小時顯示一個刻度
                     expand = c(0,0)  # 移除左右兩側多餘的空白
                     )+
  labs(title = "Average Steps in 24 Hours", x = "Hour", y = "Average Steps")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 16))

ggplot(data = hourly_trend, aes(x = Hour, y = avg_colories)) +
  geom_col(fill = "steelblue")+
  scale_x_continuous(limits = c(-0.5, 23.5),  # 讓 0 和 24 的直條不會被切到邊緣
                     breaks = seq(0, 23, by = 2),  # 每2小時顯示一個刻度
                     expand = c(0,0)  # 移除左右兩側多餘的空白
                     )+
  labs(title = "Average Colories Burned in 24 Hours", x = "Hour", y = "Average Calories Burned")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 16))


# B - 個體關係 Scatter plot + Linear Regression Model -- StepTotal & Calories

## B1 - Using "stat_poly_eq()" describe linear formula 
ggplot(data = hourly_merged, aes(x = StepTotal, y = Calories))+
  geom_point(alpha = 0.15, colour = "darkblue")+
  geom_smooth(method = "lm", colour = "red", se = TRUE) +
  stat_poly_eq(aes(label = paste(after_stat(eq.label),
                                 after_stat(adj.rr.label),
                                 sep = "*\", \"*")),
               formula = y ~ x,
               parse = TRUE,  # 啟用數學表達式解析，讓方程式和符號正確顯示
               label.x = "right",
               label.y = "top")+
  theme_light()+
  labs(title = "Relationship between Hourly Total Steps and Calories Burned",
       x = "Total Steps per Hour",
       y = "Calories Burned per Hour")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 16))

## B2 - Scatter plot + marginal plots + linear regression (with formula)
# -- Linear Model --
calories_model <- lm(Calories ~ StepTotal, data = hourly_merged)
summary_model <- summary(calories_model)
#print(summary_model)
## (Summary) y = 74.44 + 0.07166x
## Intercept 截距=74.44：即便在靜止的狀況下，人也會有基礎代謝率(Basal Metabolic Rate)，與維持生命器官運作所需的能量消耗
## Adjusted-R^ =0.66422：『每小時的步行總步數』，能解釋卡路里總消耗量中 66% 的變異量

# -- Extract Coefficient --
adj_r_squared <- summary_model$adj.r.squared
intercept <- coef(calories_model)[1]
slope <- coef(calories_model)[2]

# -- Formatting: y = ax + b --
label_text <- sprintf("y = %.2f + %.4f x\nR\u00B2 = %.3f", intercept, slope, adj_r_squared)

# -- Main Plot --
mp <- ggplot(data = hourly_merged, aes(x = StepTotal, y = Calories))+
  geom_point(alpha = 0.15, colour = "blue")+
  geom_smooth(method = "lm", colour = "red", se = TRUE) +
  theme_light()+
  labs(x = "Total Steps per Hour",
       y = "Calories Burned per Hour")+
  annotate("text", # 手動加入文字
           x = 7000, y = 870, # 自行決定要放的座標位置
           label = label_text,
           color = "black",
           size = 3.5,
           hjust = 0, # 文字靠左對齊
           fontface = "bold")
  
# -- Add marginal plots [package: "ggExtra"]--
mp_marginal <- ggMarginal(mp, 
           type = "density",  # "density" or "histogram"
           margins = "both",  # xy 軸都加
           fill = "lightblue",
           alpha = 0.6)

# -- Add title (原本的寫法標題會被擠出畫布而被切掉)
# patchwork 套件:能把大標題當作一個獨立的「頂部區塊」跟下方組裝好的圖表疊加，這樣標題跟圖表就絕對不會互相侵犯
wrap_elements(mp_marginal) + 
  plot_annotation(
    title = "Relationship between Hourly Total Steps and Calories Burned",
    theme = theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14)))
  
# C - Regression Diagnostics
par(mfrow = c(2,2)) # 可以把畫布切成 2x2，讓 4 張診斷圖一次呈現
plot(calories_model) 
## C1 - Residuals vs Fitted 殘差與預測值圖：檢查模型是否具有「線性關係」及「變異數同質性」
## C2 - Normal Q-Q: 檢查殘差是否呈現常態分配
## C3 - Scale-Location 標準化殘差開根號圖：同樣用於檢查殘差的變異數同質性（同質性檢定）
## C4 - Residuals vs Leverage 殘差與槓桿值圖：尋找數據中是否有「異常值 Outliers」或「高槓桿點 High Leverage Points」

# D - 個體關係 Scatter plot + Linear Regression Model -- TotalIntensity & Calories
ggplot(data = hourly_merged, aes(x = TotalIntensity, y = Calories))+
  geom_point(alpha = 0.15, colour = "darkblue")+
  geom_smooth(method = "lm", colour = "red", se = TRUE) +
  stat_poly_eq(aes(label = paste(after_stat(eq.label),
                                 after_stat(adj.rr.label),
                                 sep = "*\", \"*")),
               formula = y ~ x,
               parse = TRUE,  # 啟用數學表達式解析，讓方程式和符號正確顯示
               label.x = "right",
               label.y = "top")+
  theme_light()+
  labs(title = "Relationship between Hourly Total Intensity and Calories Burned",
       x = "Total Intensity per Hour",
       y = "Calories Burned per Hour")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14))

intensity_model <- lm(Calories ~ TotalIntensity, data = hourly_merged)
summary(intensity_model)

# E - Multiple Linear Regression：同時納入步數與活動強度
calories_multi_model <- lm(Calories ~ StepTotal + TotalIntensity, data = hourly_merged)
summary(calories_multi_model)

par(mfrow = c(2,2))
plot(calories_multi_model)

