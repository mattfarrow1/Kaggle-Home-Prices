# Load libraries
library(tidyverse)
library(hrbrthemes)
library(scales)

# Load data
test <- read_csv("test.csv")
train <- read_csv("train.csv")

# Look at data
glimpse(train)

# Build model
model <- lm(SalePrice ~ Neighborhood + GrLivArea, data = train)
summary(model)

# Explore the data
train %>% 
  ggplot(aes(GrLivArea, SalePrice)) +
  geom_point(shape = 1, alpha = 0.3) +
  geom_smooth(method = "lm") +
  scale_y_continuous(label = dollar) +
  labs(title = "Kaggle Home Prices Project",
       x = "Living Area Square Footage",
       y = "Sale Price") +
  theme_ipsum() +
  NULL
