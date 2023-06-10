Select *
From DataProject..NashvilleHousing

Select SaleDateConverted, Convert(date,SaleDate) as Date
From DataProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

--Property populate address data
Select *
From DataProject..NashvilleHousing
order by ParcelID
--I realised that there are duplicate data of address and parcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataProject..NashvilleHousing a
Join DataProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--We can diagnose the anomolies of same ParcelID and NULL property addresses due to duplicate entries

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataProject..NashvilleHousing a
Join DataProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--We remove the NULL duplicate entries by matching and updating.
--ISNULL function; if a.propertyaddress is null, it will return the value of b.propertyaddress

Select PropertyAddress
From DataProject..NashvilleHousing

--SUBSTRING: extract a portion of a string based on specific position and length
-- in this case, start at index 1 and end off at ,
-- -1 so that it will remove the comma 
--CHARINDEX: find the index at the specified substring
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From DataProject..NashvilleHousing
--Separating the address, state/city/street

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)			-- PARSENAME is to split between delimiter
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from DataProject..NashvilleHousing
--PARSENAME function separate strings by period .
--REPLACE , with .
-- . means period or dot

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from DataProject..NashvilleHousing

-- Change Y and N to Yes and No in 'SoldAsVacant' column

select Distinct(SoldAsVacant), count(SoldAsVacant)
from DataProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from DataProject..NashvilleHousing
group by SoldAsVacant

Update NashvilleHousing
set SoldAsVacant = case 
					when SoldAsVacant = 'Y' then 'Yes'
					when SoldAsVacant = 'N' then 'No'
					else SoldAsVacant
					end

-- Remove Duplicates (Not recommended to delete original data)
WITH RowNumCTE as(
select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) as row_num
from DataProject..NashvilleHousing
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

select *
from DataProject..NashvilleHousing

Alter table DataProject..NashvilleHousing
drop column SaleDate, OwnerAddress, TaxDistrict,PropertyAddress