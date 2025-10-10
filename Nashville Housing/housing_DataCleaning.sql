-- Data Cleaning
-- Populate the NULL/Blank Values with Known Data in PropertyAddress Column

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM nashville_staging AS a
JOIN nashville_staging AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_staging a
JOIN nashville_staging b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


-- Breakdown PropertyAddress Column Into PropertyAddress and PropertyCity

SELECT	SUBSTRING_INDEX(PropertyAddress, ',', 1) AS PropertyAddressSplit,	
		SUBSTRING_INDEX(PropertyAddress, ',', -1) AS PropertyCitySplit
FROM nashville_staging;

ALTER TABLE nashville_staging
ADD PropertyAddressSplit VARCHAR(240);

UPDATE nashville_staging
SET PropertyAddressSplit = SUBSTRING_INDEX(PropertyAddress,',', 1);


ALTER TABLE nashville_staging
ADD PropertyCitySplit VARCHAR(50);

UPDATE nashville_staging
SET PropertyCitySplit = SUBSTRING_INDEX(PropertyAddress,',', -1);


-- Convert Datatype of SaleDate Column

SELECT SaleDate, STR_TO_DATE(NULLIF(SaleDate,''),'%M %e, %Y') AS SaleDate_Upd
FROM nashville_staging;

UPDATE nashville_staging
SET SaleDate = STR_TO_DATE(NULLIF(SaleDate,''),'%M %e, %Y');


-- Convert Datatype and Standardize SalePrice Column

SELECT SalePrice
FROM nashville_staging
WHERE SalePrice LIKE '%$%';

SELECT SalePrice, REGEXP_REPLACE(TRIM(SalePrice),'[$,]','')
FROM nashville_staging
WHERE SalePrice LIKE '%$%';

UPDATE nashville_staging
SET SalePrice = CAST(REGEXP_REPLACE(TRIM(SalePrice),'[$,]','') AS SIGNED);


-- Standardize SoldAsVacant

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM nashville_staging
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
	CASE 	WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
	END
FROM nashville_staging;
		

UPDATE nashville_staging
SET SoldAsVacant =	CASE 	WHEN SoldAsVacant = 'N' THEN 'No'
							WHEN SoldAsVacant = 'Y' THEN 'Yes'
							ELSE SoldAsVacant
	END;


-- Breakdown OwnerAddress Column Into OwnerAddress, OwnerCity and OwnerState

SELECT	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerAddressSplit,	
		SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',-2), ',',1) AS OwnerCitySplit,
		SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerStateSplit
FROM nashville_staging;

ALTER TABLE nashville_staging
ADD OwnerAddressSplit VARCHAR(240);

UPDATE nashville_staging
SET OwnerAddressSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);


ALTER TABLE nashville_staging
ADD OwnerCitySplit VARCHAR(50);

UPDATE nashville_staging
SET OwnerCitySplit = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',-2), ',',1);


ALTER TABLE nashville_staging
ADD OwnerStateSplit VARCHAR(50);

UPDATE nashville_staging
SET OwnerStateSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);


SELECT *
FROM nashville_staging;

-- Remove Duplicates

WITH RowNumCTE AS (
	SELECT 	*,
			ROW_NUMBER() OVER (
				PARTITION BY 
					ParcelID,
					LandUse,
					PropertyAddress,
					SaleDate,
					SalePrice
	ORDER BY UniqueID) AS row_num
	FROM nashville_staging
	ORDER BY UniqueID)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS (
	SELECT *,
			ROW_NUMBER() OVER (
				PARTITION BY
					ParcelID,
					LandUse,
					PropertyAddress,
					SaleDate,
					SalePrice
	ORDER BY UniqueID) AS row_num
	FROM nashville_staging
	ORDER BY UniqueID)
DELETE h
FROM nashville_staging h
JOIN RowNumCTE r
	ON h.UniqueID = r.UniqueID
WHERE r.row_num > 1;


-- Drop Unnecessary Columns

ALTER TABLE nashville_staging
DROP COLUMN PropertyAddress,
DROP COLUMN LegalReference,
DROP COLUMN OwnerAddress;

SELECT * 
FROM nashville_staging;
