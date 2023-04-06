/*

Cleaning Data with SQL Queries

*/

SELECT
	*
FROM
	Portfolio_Project.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------------
-- Standarize Date Format

SELECT
	SaleDate,
	CONVERT(Date, SaleDate)
FROM
	Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



---------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

SELECT
	*
FROM
	Portfolio_Project.dbo.NashvilleHousing
WHERE
	PropertyAddress is null
ORDER BY
	ParcelID


Select
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	Portfolio_Project.dbo.NashvilleHousing a
JOIN 
	Portfolio_Project.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	Portfolio_Project.dbo.NashvilleHousing a
JOIN 
	Portfolio_Project.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null



---------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
	*
FROM
	Portfolio_Project.dbo.NashvilleHousing


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS City
FROM
	Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM
	Portfolio_Project.dbo.NashvilleHousing
ORDER BY
	OwnerAddress DESC

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



---------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "SoldAsVacant" field

SELECT
	DISTINCT(SoldAsVacant),
	Count(SoldAsVacant)
FROM
	Portfolio_Project.dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2


SELECT
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM
	Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END



---------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
						) row_num

FROM
	Portfolio_Project.dbo.NashvilleHousing
)

DELETE
FROM
	RowNumCTE
WHERE
	row_num > 1



---------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT
	*
FROM
	Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE
	Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN
	SaleDate,
	OwnerAddress,
	TaxDistrict,
	PropertyAddress
