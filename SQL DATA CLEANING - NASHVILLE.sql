/*

CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM PortfolioProject..NashvilleHousingData

-- STANDARIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--POPULATE PROPERT ADDRESS DATA

SELECT *
FROM PortfolioProject..NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData AS a
JOIN PortfolioProject..NashvilleHousingData AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData AS a
JOIN PortfolioProject..NashvilleHousingData AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--Breaking out Address into Individual Columns (Adress, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingData


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM PortfolioProject..NashvilleHousingData


ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity  Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))










SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingData


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousingData


ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity  Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM PortfolioProject..NashvilleHousingData




-- Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant


UPDATE NashvilleHousingData
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END





-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousingData
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1




-- DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN 
	OwnerAddress,
	TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN 
	SaleDate
