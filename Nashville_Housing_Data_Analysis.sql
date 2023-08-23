-- Cleaning Data in SQL, Data cleaning project

Select *
From `nashville housing data`

-- Create a new column in the table with SalesDate format YY-MM-DD
-- If time was also added alongside date, we should use the following function to separate the two:
-- SELECT DATE_FORMAT (SalesDate, '%y-%m-%d') AS Date, DATE_FORMAT ( SalesDate, '%H:%i:%s') AS Time FROM `nashville housing data`
SELECT DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%y-%m-%d') AS Sale_Date_Converted -- This function converted the original string values of SaleDate to numerical values
FROM `nashville housing data`

ALTER TABLE `nashville housing data` -- Adding a new Column to the table for converted sales date
ADD Sale_Date_Converted Date

UPDATE `nashville housing data` -- Updating the new added column to the table to include the new numeric SaleDate values
SET Sale_Date_Converted = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%y-%m-%d')

-- Populate null Property Address Data based on matching ParcelID
SELECT *
FROM `nashville housing data`
-- WHERE PropertyAddress is NULL -- Identifying which rows are populating null values for property address so we can address the issue
ORDER BY ParcelID

-- Joined the same table to itself where parcelID is the same but it is not the same row due to the UniqueID
-- Matching parcelIDs and property address to fix NULL values 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM `nashville housing data` a
JOIN `nashville housing data` b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b. UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropetyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM `nashville housing data` a
JOIN `nashville housing data` b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b. UniqueID
WHERE a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns
SELECT PropertyAddress
FROM `nashville housing data`

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +2) AS City
FROM `nashville housing data`

-- Updating Table to include split addresses
ALTER TABLE `nashville housing data`
ADD PropertySplitAddress CHAR(255)

UPDATE `nashville housing data`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1)

ALTER TABLE `nashville housing data`
ADD PropertySplitCity CHAR(255)

UPDATE `nashville housing data`
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +2)

-- Change SoldAsVacant Column 'Y and N' to 'Yes and No' for better analysis with CASE Statements
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM `nashville housing data`
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM `nashville housing data`

UPDATE `nashville housing data`
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;
    
-- Removing Duplicates 
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
	ORDER BY UniqueID
) AS row_num
FROM `nashville housing data`
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

DELETE n1
FROM `nashville housing data` n1
JOIN (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, MIN(UniqueID) AS min_id
    FROM `nashville housing data`
    GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
) n2 ON n1.ParcelID = n2.ParcelID
    AND n1.PropertyAddress = n2.PropertyAddress
    AND n1.SalePrice = n2.SalePrice
    AND n1.SaleDate = n2.SaleDate
    AND n1.LegalReference = n2.LegalReference
    AND n1.UniqueID > n2.min_id;
    
-- Delete unused columns 
ALTER TABLE `nashville housing data`
DROP COLUMN PropertyAddress
