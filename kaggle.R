
# Setup -------------------------------------------------------------------

# Load libraries
library(tidyverse)
library(hrbrthemes)
library(scales)
library(tidymodels)

# Load data
test <- read_csv("test.csv")
train <- read_csv("train.csv")

# Look at data
glimpse(train)

# Build model
model <- lm(SalePrice ~ Neighborhood + GrLivArea, data = train)
summary(model)

# Problem 1 ---------------------------------------------------------------

# Specific neighborhoods
neighborhoods <- c("NAmes", "Edwards", "BrkSide")

# Explore the data
train %>% 
  filter(Neighborhood %in% neighborhoods) %>% 
  ggplot(aes(GrLivArea, SalePrice, color = Neighborhood)) +
  geom_point(shape = 1, alpha = 0.5) +
  geom_smooth(method = "lm") +
  scale_y_continuous(label = dollar) +
  labs(title = "Kaggle Home Prices Project",
       x = "Living Area Square Footage",
       y = "Sale Price") +
  theme_ipsum() +
  NULL

# Filter training set
train1 <- train %>% 
  filter(Neighborhood %in% neighborhoods) %>%     # Filter to specific neighborhoods
  select(Neighborhood, GrLivArea, SalePrice) %>%  # Only columns of interest
  mutate(sq_foot = round(GrLivArea, digits = -2)) # New column with square footage to nearest 100

# Build a model
model <- lm(SalePrice ~ Neighborhood + sq_foot, data = train1)
summary(model)

# Problem 2 ---------------------------------------------------------------


