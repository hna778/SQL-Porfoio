-- Load Data Into Database
-- 1. Create Raw Data Table

USE housing;

DROP TABLE IF EXISTS nashville;

CREATE TABLE nashville (
		UniqueID VARCHAR(20),
		ParcelID VARCHAR(30),
        LandUse VARCHAR(250),
        PropertyAddress VARCHAR(250),
        SaleDate VARCHAR(50),
        SalePrice VARCHAR(50),
        LegalReference VARCHAR(250),
        SoldAsVacant VARCHAR(250),
        OwnerName VARCHAR(250),
        OwnerAddress VARCHAR(250),
        Acreage VARCHAR(50),
        TaxDistrict VARCHAR(250),
        LandValue VARCHAR(50),
        BuildingValue VARCHAR(250),
        TotalValue VARCHAR(50),
        YearBuilt VARCHAR(10),
        Bedrooms VARCHAR(10),
        FullBath VARCHAR(10),
        HalfBath VARCHAR(10)
);

LOAD DATA LOCAL INFILE '/Users/hna/Documents/DA/SQL/Housing/Nashville Housing.csv'
INTO TABLE nashville
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
UniqueID,
ParcelID,
LandUse,
@PropertyAddress,
@SaleDate,
SalePrice,
LegalReference,
SoldAsVacant,
@OwnerName,
@OwnerAddress,
@Acreage,
@TaxDistrict,
@LandValue,
@Buildingvalue,
@TotalValue,
@YearBuilt,
@Bedrooms,
@FullBath,
@HalfBath
)
SET
PropertyAddress = NULLIF(@PropertyAddress, ''),
SaleDate = NULLIF(@SaleDate, ''),
OwnerName = NULLIF(@OwnerName, ''),
OwnerAddress = NULLIF(@OwnerAddress, ''),
Acreage = NULLIF(@Acreage, ''),
TaxDistrict = NULLIF(@TaxDistrict, ''),
LandValue = NULLIF(@LandValue, ''),
BuildingValue = NULLIF(@BuildingValue, ''),
TotalValue = NULLIF(@TotalValue, ''),
YearBuilt = NULLIF(@YearBuilt, ''),
Bedrooms = NULLIF(@Bedrooms, ''),
FullBath = NULLIF(@FullBath, ''),
HalfBath = NULLIF(@HalfBath, '')
;

SELECT *
FROM nashville;

-- 2. Create Staging Table

DROP TABLE IF EXISTS nashville_staging;

CREATE TABLE nashville_staging 
LIKE nashville;

INSERT nashville_staging 
SELECT *
FROM nashville;

SELECT * 
FROM nashville_staging;

-- 3. Initial check

SELECT count(DISTINCT UniqueID), count(UniqueID)
FROM nashville_staging;

SELECT count(DISTINCT ParcelID), count(ParcelID)
FROM nashville_staging;

SELECT
  SUM(UniqueID      IS NULL) AS null_UniqueID,
  SUM(ParcelID      IS NULL) AS null_ParcelID,
  SUM(LandUse       IS NULL) AS null_LandUse,
  SUM(PropertyAddress IS NULL) AS null_PropertyAddress,
  SUM(SaleDate      IS NULL) AS null_SaleDate,
  SUM(SalePrice     IS NULL) AS null_SalePrice,
  SUM(SoldAsVacant  IS NULL) AS null_SoldAsVacant,
  SUM(OwnerAddress  IS NULL) AS null_OwnerAddress,
  SUM(Acreage       IS NULL) AS null_Acreage,
  SUM(LandValue     IS NULL) AS null_LandValue,
  SUM(BuildingValue IS NULL) AS null_BuildingValue,
  SUM(TotalValue    IS NULL) AS null_TotalValue,
  SUM(YearBuilt     IS NULL) AS null_YearBuilt,
  SUM(Bedrooms      IS NULL) AS null_Bedrooms,
  SUM(FullBath      IS NULL) AS null_FullBath,
  SUM(HalfBath      IS NULL) AS null_HalfBath
FROM nashville_staging;