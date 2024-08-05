select *
from Portfolio_Project.dbo.NashvilleHousing


--------------------------------------------------------------------
-- Standardlize Date Format

select SaleDateConverd
from Portfolio_Project.dbo.NashvilleHousing


update NashvilleHousing
set SaleDate =CONVERT(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverd date;

update NashvilleHousing
set SaleDateConverd = CONVERT(date,SaleDate)


--------------------------------------------------------------------

--Populate Property Address date

select *
from Portfolio_Project.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID


select a.ParcelID , b.PropertyAddress , b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-----------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID



select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress) )as city

from Portfolio_Project.dbo.NashvilleHousing





alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress) )




------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
select OwnerAddress
from Portfolio_Project.dbo.NashvilleHousing


select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from Portfolio_Project.dbo.NashvilleHousing



alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress =PARSENAME(replace(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity =PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState =PARSENAME(replace(OwnerAddress,',','.'),1)


-----------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select  distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Portfolio_Project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes' 
		when SoldAsVacant = 'N' then 'NO'
		else SoldAsVacant
		end 
from Portfolio_Project.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = 	case when SoldAsVacant = 'Y' then 'Yes' 
		when SoldAsVacant = 'N' then 'NO'
		else SoldAsVacant
		end 


----------------------------------------------------
-- Remove Duplicates

with RowNumCTE as(
select *, 
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

----------------------------------------------------------------------------------

-- Delete Unused Columns


select *
from Portfolio_Project.dbo.NashvilleHousing


alter table Portfolio_Project.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate





