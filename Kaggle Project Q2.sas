PROC IMPORT OUT= WORK.Train 
            DATAFILE= "Y:\R\Kaggle-Home-Prices\train.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= WORK.Test 
            DATAFILE= "Y:\R\Kaggle-Home-Prices\test.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/* Log Transform Sales and Square Footage */
data TrainQ1;
set Train;
LogSalePrice = log(SalePrice);
LogLiving = log(GrLivArea);
run;

/*FOR BYOA*/
PROC GLM DATA = TrainQ1 (WHERE =(NEIGHBORHOOD IN ("NAmes", "Edwards","BrkSide")));
CLASS NEIGHBORHOOD;
MODEL LogSalePrice = LogLiving | NEIGHBORHOOD / solution;
RUN;
PROC GLM DATA = TrainQ1 (WHERE =(NEIGHBORHOOD IN ("NAmes", "Edwards","BrkSide"))) plots=all; CLASS NEIGHBORHOOD;
MODEL LogSalePrice = LogLiving Neighborhood/ solution;
RUN;

/*FOR FORWARD,BACKWARD, AND STEPWISE*/
DATA TEST_Log;
SET Test;
LogSalePrice = .;
run;

DATA TrainQ2 (DROP = GrLivArea);
SET TrainQ1;
LIVING = ROUND(GrLivArea,100);
RUN;

DATA TestQ2 (DROP = GrLivArea);
SET Test_Log;
LIVING = ROUND(GrLivArea,100);
LogLiving = LOG(LIVING);
RUN;

PROC SQL;CREATE TABLE NEIGHBORHOODS AS SELECT DISTINCT NEIGHBORHOOD FROM TRAIN;QUIT;

ods graphics on;

/*
Forward
*/
proc glmselect data=TrainQ2 TESTDATA= work.TestQ2 plots=all;
CLASS Alley BldgType BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 BsmtQual CentralAir Condition1 Condition2 Electrical ExterCond ExterQual Exterior1st Exterior2nd Fence FireplaceQu Foundation Functional GarageCond GarageFinish GarageQual GarageType Heating HeatingQC HouseStyle KitchenQual LandContour LandSlope LotConfig LotFrontage LotShape MSZoning MasVnrType MiscFeature Neighborhood PavedDrive PoolQC RoofMatl RoofStyle SaleCondition SaleType Street Utilities
;
model LogSalePrice = MSSubClass MSZoning LotFrontage LotArea Street Alley LotShape
LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle RoofMatl Exterior1st Exterior2nd MasVnrType MasVnrArea ExterQual ExterCond Foundation BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinSF1 BsmtFinType2 BsmtFinSF2 BsmtUnfSF TotalBsmtSF
Heating HeatingQC CentralAir Electrical _1stFlrSF _2ndFlrSF LowQualFinSF
BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu GarageType GarageYrBlt GarageFinish GarageCars GarageArea GarageQual GarageCond PavedDrive WoodDeckSF OpenPorchSF EnclosedPorch _3SsnPorch ScreenPorch PoolArea PoolQC Fence MiscFeature MiscVal MoSold YrSold SaleType SaleCondition Living LogLiving
/ selection = Forward(select = ADJRSQ stop = CV SLE = .15) /*details=all stats=all*/; run;

/*
Backward
*/
proc glmselect data=TrainQ2 TESTDATA= work.TestQ2 plots=all;
CLASS Alley BldgType BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 BsmtQual CentralAir Condition1 Condition2 Electrical ExterCond ExterQual Exterior1st Exterior2nd Fence FireplaceQu Foundation Functional GarageCond GarageFinish GarageQual GarageType Heating HeatingQC HouseStyle KitchenQual LandContour LandSlope LotConfig LotFrontage LotShape MSZoning MasVnrType MiscFeature Neighborhood PavedDrive PoolQC RoofMatl RoofStyle SaleCondition SaleType Street Utilities
;

 model LogSalePrice = MSSubClass MSZoning LotFrontage LotArea Street Alley LotShape
LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle RoofMatl Exterior1st Exterior2nd MasVnrType MasVnrArea ExterQual ExterCond Foundation BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinSF1 BsmtFinType2 BsmtFinSF2 BsmtUnfSF TotalBsmtSF
Heating HeatingQC CentralAir Electrical _1stFlrSF _2ndFlrSF LowQualFinSF
BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu GarageType GarageYrBlt GarageFinish GarageCars GarageArea GarageQual GarageCond PavedDrive WoodDeckSF OpenPorchSF EnclosedPorch _3SsnPorch ScreenPorch PoolArea PoolQC Fence MiscFeature MiscVal MoSold YrSold SaleType SaleCondition Living LogLiving
/ selection = Backward(select = ADJRSQ stop = CV CHOOSE = CV) /*details=all stats=all*/; run;

/*
Stepwise
*/
proc glmselect data=TrainQ2 TESTDATA= work.TestQ2 plots=all;
CLASS Alley BldgType BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 BsmtQual CentralAir Condition1 Condition2 Electrical ExterCond ExterQual Exterior1st Exterior2nd Fence FireplaceQu Foundation Functional GarageCond GarageFinish GarageQual GarageType Heating HeatingQC HouseStyle KitchenQual LandContour LandSlope LotConfig LotFrontage LotShape MSZoning MasVnrType MiscFeature Neighborhood PavedDrive PoolQC RoofMatl RoofStyle SaleCondition SaleType Street Utilities
;
model LogSalePrice = MSSubClass MSZoning LotFrontage LotArea Street Alley LotShape
LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle RoofMatl Exterior1st Exterior2nd MasVnrType MasVnrArea ExterQual ExterCond Foundation BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinSF1 BsmtFinType2 BsmtFinSF2 BsmtUnfSF TotalBsmtSF
Heating HeatingQC CentralAir Electrical _1stFlrSF _2ndFlrSF LowQualFinSF
BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu GarageType GarageYrBlt GarageFinish GarageCars GarageArea GarageQual GarageCond PavedDrive WoodDeckSF OpenPorchSF EnclosedPorch _3SsnPorch ScreenPorch PoolArea PoolQC Fence MiscFeature MiscVal MoSold YrSold SaleType SaleCondition Living LogLiving
/ selection = STEPWISE(select = ADJRSQ stop = CV slentry = .15 SLE = .15) /*details=all stats=all*/; run;

/*
Custom Model
*/
proc glmselect data = TrainQ2 TESTDATA= work.TestQ2 PLOTS=all;
CLASS Neighborhood MSZoning HouseStyle CentralAir GarageFinish SaleCondition BsmtQual ExterQual KitchenQual LotFrontage BsmtFinType1;
model LogSalePrice = LogLiving Neighborhood MSZoning
HouseStyle GarageArea GarageCars OverallQual
TotalBsmtSF CentralAir GarageFinish ExterQual _1stFlrSF FullBath YearBuilt YearRemodAdd SaleCondition KitchenQual BsmtQual BsmtFinType1
BsmtFinType1*TotalBsmtSF TotRmsAbvGrd LotFrontage Neighborhood*LogLiving 
/ selection = STEPWISE(select = ADJRSQ stop = CV slentry = .15 SLE = .15) /*details=all stats=all*/; run;

proc glmselect data = TrainQ2 TESTDATA= work.TestQ2 PLOTS=all;
