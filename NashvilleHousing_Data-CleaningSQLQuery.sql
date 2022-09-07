/* 
Cleaning  data in SQL
*/

Select * 
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate) 
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET saledate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add saleDateConverted Date

Update NashvilleHousing
SET saleDateCoverted = CONVERT(Date, SaleDate)

-------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address 
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
from PortfolioProject..NashvilleHousing


Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
from PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "sold as vacant" field

Select Distinct(SoldAsVacant), COUNT(soldasvacant)

from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
,	CASE when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
						 when SoldAsVacant = 'N' Then 'No'
						 ELSE SoldAsVacant
						 END



------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from PortfolioProject..NashvilleHousing
-- Order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



-------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * 
from PortfolioProject..NashvilleHousing

ALTER TABLE  PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE  PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate