
# Setup -------------------------------------------------------------------

# Load libraries
library(tidyverse)
library(hrbrthemes) # clean plotting theme
library(scales)     # format scales

# Load data
test <- read_csv("test.csv")
train <- read_csv("train.csv")

# Clean up column names
test <- janitor::clean_names(test)
train <- janitor::clean_names((train))

# Look at data
glimpse(train)

# Problem 1 ---------------------------------------------------------------

# Explore the data
train %>% 
  filter(neighborhood %in% c("NAmes", "Edwards", "BrkSide")) %>% 
  ggplot(aes(gr_liv_area, sale_price, color = neighborhood)) +
  geom_point(shape = 1, alpha = 0.5) +
  geom_smooth(method = "lm") +
  scale_y_continuous(label = dollar) +
  labs(title = "Kaggle Home Prices Project",
       x = "Living Area Square Footage",
       y = "Sale Price") +
  theme_ipsum() +
  NULL

# Filter training set
train_by_neighborhood <- train %>% 
  filter(neighborhood %in% c("NAmes", "Edwards", "BrkSide")) %>% 
  mutate(sq_foot = round(gr_liv_area, digits = -2),
         log_sq_foot = log(sq_foot),
         log_sale_price = log(sale_price)) %>% 
  select(id, sq_foot, log_sq_foot,  neighborhood, sale_price, log_sale_price)

# train_by_neighborhood %>% 
#   ggpairs() +
#   labs(title = "ABV by IBU Distribution")

# Identify outliers
outliers <- boxplot(train_by_neighborhood$log_sale_price, plot = FALSE)$out
train_by_neighborhood_outliers <- train_by_neighborhood %>% 
  filter(!log_sale_price %in% outliers)

# Multiple linear regresssion model
model <- lm(log_sale_price ~ log_sq_foot + neighborhood + log_sq_foot*neighborhood, data = train_by_neighborhood)
summary(model)
par(mfrow = c(2, 2))
plot(model)
rss <- c(crossprod(model$residuals))
mse <- rss / length(model$residuals)
rmse <- sqrt(mse)
sig2 <- rss / model$df.residual

# Plot residuals
model %>% 
  ggplot(aes(model$residuals)) +
  geom_histogram(bins = 20, color = "black", fill = "purple4") + 
  labs(title = "Histogram for Model Residuals",
      x = "Residuals",
      y = "Count") +
  theme_ipsum() +
  NULL

# Test model of log square footage
test_by_neighborhood <- test %>% 
  filter(neighborhood %in% c("NAmes", "Edwards","BrkSide")) %>% 
  mutate(sq_foot = round(gr_liv_area, digits = -2),
         log_sq_foot = log(sq_foot))

predict_sale_price <- predict(model, 
                              newdata = test_by_neighborhood, 
                              interval = "prediction")