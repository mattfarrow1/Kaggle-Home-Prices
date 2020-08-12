/* Load Data */

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

/*FOR BYOA IN QUESTION 1*/
PROC GLM DATA = TrainQ1 (WHERE =(NEIGHBORHOOD IN ("NAmes", "Edwards","BrkSide")));
CLASS NEIGHBORHOOD;
MODEL LogSalePrice = LogLiving | NEIGHBORHOOD / solution;
RUN;

PROC GLM DATA = TrainQ1 (WHERE =(NEIGHBORHOOD IN ("NAmes", "Edwards","BrkSide"))) plots=all;
CLASS NEIGHBORHOOD;
MODEL LogSalePrice = LogLiving Neighborhood/ solution;
RUN;

/* QUESTION 2 */

/*FOR FORWARD,BACKWARD, AND STEPWISE*/
DATA TEST_Log;
SET TEST;
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
data combined (Drop= GrLivArea);
set
               TrainQ2 (in=a)
               TestQ2 (in = b);
if in = a then group = 'a';
               else group = 'b';
run;

proc glmselect data=combined plots=all;
               partition roleVar=group(TRAIN='b' TEST='a');
               CLASS Alley         BldgType             BsmtCond           BsmtExposure    BsmtFinType1     BsmtFinType2    
               BsmtQual            CentralAir            Condition1          Condition2          Electrical             ExterCond           ExterQual              
               Exterior1st          Exterior2nd         Fence    FireplaceQu        Foundation         Functional           GarageCond      
               GarageFinish       GarageQual        GarageType        Heating HeatingQC          HouseStyle          KitchenQual       
               LandContour      LandSlope           LotConfig            LotFrontage        LotShape             MSZoning            MasVnrType              
               MiscFeature        Neighborhood    PavedDrive          PoolQC RoofMatl             RoofStyle            SaleCondition
               SaleType              Street    Utilities
;
   model LogSalePrice = MSSubClass          MSZoning            LotFrontage        LotArea Street    Alley      LotShape            
   LandContour   Utilities LotConfig            LandSlope           Neighborhood    Condition1          Condition2          BldgType
   HouseStyle       OverallQual         OverallCond        YearBuilt              YearRemodAdd  RoofStyle            RoofMatl               Exterior1st
   Exterior2nd      MasVnrType       MasVnrArea        ExterQual            ExterCond           Foundation         BsmtQual               BsmtCond          
   BsmtExposure BsmtFinType1     BsmtFinSF1         BsmtFinType2     BsmtFinSF2         BsmtUnfSF          TotalBsmtSF      
   Heating             HeatingQC          CentralAir            Electrical             _1stFlrSF              _2ndFlrSF             LowQualFinSF
   BsmtFullBath   BsmtHalfBath     FullBath               HalfBath              BedroomAbvGr  KitchenAbvGr      KitchenQual
   TotRmsAbvGrd               Functional           Fireplaces            FireplaceQu        GarageType        GarageYrBlt        GarageFinish               GarageCars
   GarageArea     GarageQual        GarageCond       PavedDrive          WoodDeckSF      OpenPorchSF      EnclosedPorch               _3SsnPorch
   ScreenPorch    PoolArea             PoolQC Fence    MiscFeature        MiscVal MoSold YrSold    SaleType              SaleCondition
   Living LogLiving
/ selection = Forward(select = ADJRSQ stop = CV SLE = .15) /*details=all stats=all*/;
 
output out=TEST_PREDICT_FORWARD sampleFreq=sf samplePred=sp PREDICTED=predicted R=r
p=p stddev=stddev lower=q25 upper=q75 median;
run;

DATA PREDICTED_FORWARD (KEEP= ID _Role_ SalePricePredicted SalePrice LogSalePrice);
SET TEST_PREDICT_FORWARD
(WHERE=(id > 1460));
SalePricePredicted = exp(predicted);
RUN;

DATA KAGGLE_FORWARD_SELECTION (keep= ID SalePrice);
SET PREDICTED_FORWARD;
SalePrice = SalePricePredicted;
run;

/*
 
Backward
 
*/
proc glmselect data=combined plots=all;
               partition roleVar=group(test='a' train='b');
               CLASS Alley         BldgType             BsmtCond           BsmtExposure    BsmtFinType1               BsmtFinType2    
               BsmtQual            CentralAir            Condition1          Condition2          Electrical               ExterCond           ExterQual           
               Exterior1st          Exterior2nd         Fence    FireplaceQu        Foundation         Functional               GarageCond      
               GarageFinish       GarageQual        GarageType        Heating HeatingQC          HouseStyle               KitchenQual       
               LandContour      LandSlope           LotConfig            LotFrontage        LotShape               MSZoning            MasVnrType      
               MiscFeature        Neighborhood    PavedDrive          PoolQC RoofMatl             RoofStyle               SaleCondition
               SaleType              Street    Utilities
;
   model LogSalePrice = MSSubClass          MSZoning            LotFrontage        LotArea Street               Alley      LotShape            
   LandContour   Utilities LotConfig            LandSlope           Neighborhood    Condition1               Condition2          BldgType
   HouseStyle       OverallQual         OverallCond        YearBuilt              YearRemodAdd  RoofStyle               RoofMatl             Exterior1st
   Exterior2nd      MasVnrType       MasVnrArea        ExterQual            ExterCond           Foundation               BsmtQual            BsmtCond          
   BsmtExposure BsmtFinType1     BsmtFinSF1         BsmtFinType2     BsmtFinSF2         BsmtUnfSF               TotalBsmtSF      
   Heating             HeatingQC          CentralAir            Electrical             _1stFlrSF              _2ndFlrSF               LowQualFinSF    
   BsmtFullBath   BsmtHalfBath     FullBath               HalfBath              BedroomAbvGr               KitchenAbvGr      KitchenQual
   TotRmsAbvGrd               Functional           Fireplaces            FireplaceQu        GarageType               GarageYrBlt        GarageFinish       GarageCars
   GarageArea     GarageQual        GarageCond       PavedDrive          WoodDeckSF               OpenPorchSF      EnclosedPorch   _3SsnPorch
   ScreenPorch    PoolArea             PoolQC Fence    MiscFeature        MiscVal MoSold YrSold               SaleType              SaleCondition
   Living LogLiving
/ selection = Backward(select = ADJRSQ stop = CV CHOOSE = CV) /*details=all stats=all*/;
output out=TEST_PREDICT_BACKWARD sampleFreq=sf samplePred=sp PREDICTED=predicted R=r
p=p stddev=stddev lower=q25 upper=q75 median;
run;

DATA PREDICTED_BACKWARD;
SET TEST_PREDICT_BACKWARD
(WHERE=(id > 1460));
SalePricePredicted = exp(predicted);
RUN;

PROC SQL;
CREATE TABLE
               BACKWARD_WITH_AVERAGE
AS SELECT DISTINCT
               *
               ,AVG(SalePricePredicted) AS AvgSalePricePredicted
FROM PREDICTED_BACKWARD
;
QUIT;

DATA KAGGLE_BACKWARD_SELECTION (keep= ID SalePrice);
SET BACKWARD_WITH_AVERAGE;
IF MISSING(SalePricePredicted) THEN SalePrice = AvgSalePricePredicted;
               ELSE SalePrice = SalePricePredicted;
run;

/*
 
Stepwise
 
*/
proc glmselect data=combined plots=all;
               partition roleVar=group(test='a' train='b');
               CLASS Alley         BldgType             BsmtCond           BsmtExposure    BsmtFinType1               BsmtFinType2    
               BsmtQual            CentralAir            Condition1          Condition2          Electrical               ExterCond           ExterQual           
               Exterior1st          Exterior2nd         Fence    FireplaceQu        Foundation         Functional               GarageCond      
               GarageFinish       GarageQual        GarageType        Heating HeatingQC          HouseStyle               KitchenQual       
               LandContour      LandSlope           LotConfig            LotFrontage        LotShape               MSZoning            MasVnrType      
               MiscFeature        Neighborhood    PavedDrive          PoolQC RoofMatl             RoofStyle               SaleCondition
               SaleType              Street    Utilities
;
   model LogSalePrice = MSSubClass          MSZoning            LotFrontage        LotArea Street               Alley      LotShape            
   LandContour   Utilities LotConfig            LandSlope           Neighborhood    Condition1               Condition2          BldgType
   HouseStyle       OverallQual         OverallCond        YearBuilt              YearRemodAdd  RoofStyle               RoofMatl             Exterior1st
   Exterior2nd      MasVnrType       MasVnrArea        ExterQual            ExterCond           Foundation               BsmtQual            BsmtCond          
   BsmtExposure BsmtFinType1     BsmtFinSF1         BsmtFinType2     BsmtFinSF2         BsmtUnfSF               TotalBsmtSF      
   Heating             HeatingQC          CentralAir            Electrical             _1stFlrSF              _2ndFlrSF               LowQualFinSF    
   BsmtFullBath   BsmtHalfBath     FullBath               HalfBath              BedroomAbvGr               KitchenAbvGr      KitchenQual
   TotRmsAbvGrd               Functional           Fireplaces            FireplaceQu        GarageType               GarageYrBlt        GarageFinish       GarageCars
   GarageArea     GarageQual        GarageCond       PavedDrive          WoodDeckSF               OpenPorchSF      EnclosedPorch   _3SsnPorch
   ScreenPorch    PoolArea             PoolQC Fence    MiscFeature        MiscVal MoSold YrSold               SaleType              SaleCondition
   Living LogLiving
/ selection = STEPWISE(select = ADJRSQ stop = CV slentry = .15 SLE = .15) /*details=all stats=all*/;
output out=TEST_PREDICT_STEPWISE sampleFreq=sf samplePred=sp PREDICTED=predicted R=r
p=p stddev=stddev lower=q25 upper=q75 median;
run;

DATA PREDICTED_STEPWISE (KEEP= ID _Role_ SalePricePredicted SalePrice LogSalePrice);
SET TEST_PREDICT_STEPWISE
(WHERE=(id > 1460));
SalePricePredicted = exp(predicted);
RUN;

DATA KAGGLE_STEPWISE_SELECTION (keep= ID SalePrice);
SET PREDICTED_STEPWISE;
SalePrice = SalePricePredicted;
run;
/*
 
Custom Model
 
*/
proc glmselect data=combined plots=all;
               partition roleVar=group(test='a' train='b');
               CLASS Neighborhood MSZoning HouseStyle CentralAir GarageFinish SaleCondition
               BsmtQual ExterQual KitchenQual LotFrontage BsmtFinType1;
   model LogSalePrice = LogLiving | Neighborhood MSZoning
                              HouseStyle GarageArea  GarageCars OverallQual
                              TotalBsmtSF CentralAir GarageFinish ExterQual _1stFlrSF FullBath YearBuilt YearRemodAdd SaleCondition KitchenQual
                              BsmtQual BsmtFinType1 BsmtFinType1*TotalBsmtSF TotRmsAbvGrd LotFrontage Neighborhood*LogLiving
/ selection = STEPWISE(CHOOSE = ADJRSQ stop = CV slentry = .15 SLE = .15) /*details=all stats=all*/;
output out=TEST_PREDICT_CUSTOM sampleFreq=sf samplePred=sp PREDICTED=predicted R=r
p=p stddev=stddev lower=q25 upper=q75 median;
run;

proc glm data = combined plots = all;
CLASS Neighborhood MSZoning HouseStyle CentralAir GarageFinish SaleCondition
               BsmtQual ExterQual KitchenQual LotFrontage BsmtFinType1;
   model LogSalePrice = LogLiving | Neighborhood MSZoning
                              HouseStyle GarageArea  GarageCars OverallQual
                              TotalBsmtSF CentralAir GarageFinish ExterQual _1stFlrSF FullBath YearBuilt YearRemodAdd SaleCondition KitchenQual
                              BsmtQual BsmtFinType1 BsmtFinType1*TotalBsmtSF TotRmsAbvGrd LotFrontage Neighborhood*LogLiving
/ solution cli;
output out=TEST_PREDICT_CUSTOM  PREDICTED=predicted R=r p=p;
run;

DATA PREDICTED_CUSTOM (KEEP= ID _Role_ SalePricePredicted SalePrice LogSalePrice);
SET TEST_PREDICT_CUSTOM
(WHERE=(id > 1460));
SalePricePredicted = exp(predicted);
RUN;

PROC SQL;
CREATE TABLE
               CUSTOM_WITH_AVERAGE
AS SELECT DISTINCT
               *
               ,AVG(SalePricePredicted) AS AvgSalePricePredicted
FROM PREDICTED_CUSTOM
;
QUIT;

DATA KAGGLE_CUSTOM_SELECTION (keep= ID SalePrice);
SET CUSTOM_WITH_AVERAGE;
IF MISSING(SalePricePredicted) THEN SalePrice = AvgSalePricePredicted;
               ELSE SalePrice = SalePricePredicted;
run;
