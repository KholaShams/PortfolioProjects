Select *
from HousingData..NashvilleHousing;

-- Standardize SaleDate into Data format instead of Data and time

Select SaleDate
From HousingData..NashvilleHousing;

Select SaleDate, CONVERT(date, SaleDate) as DateOfSale
From HousingData..NashvilleHousing;

--update the dataset
Update HousingData..NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate); 
--not working

-- so we will alter the table and add a new column with converted values
Alter Table HousingData..NashvilleHousing
Add SaleDateConverted Date;

Update HousingData..NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate);

Select SaleDateConverted
From HousingData..NashvilleHousing;

-- Populate Property Address Data

-- Some rows in the Property Address column is empty or data is misssing. so for that, we will try to add some data into it

Select PropertyAddress
From HousingData..NashvilleHousing;

--check for null values
Select PropertyAddress
From HousingData..NashvilleHousing
Where PropertyAddress is null;

Select *
From HousingData..NashvilleHousing
Where PropertyAddress is null;


Select *
From HousingData..NashvilleHousing
--Where PropertyAddress is null;
order by ParcelID;

-- the property address could be populated if we have a reference point to base that off of
-- In the data, for the same ParcelID we have the same property address, so this parcel id can be used to fill up some of the missing values of the property address

-- we will have to do a self join to look at the same parcelid
Select *
From HousingData..NashvilleHousing a
join HousingData..NashvilleHousing b
on a.ParcelID=b.ParcelID
-- we need to find a way to distinguish the a and b
and a.[UniqueID ] <> b.[UniqueID ];
-- this line will help find the parcelid which are same but they dont have the uniqueID
-- this way we can find the propertyaddress that are not populated but with the same parcelID

-- now if the parcelid is same but the uniqueid is different we will use that to populate the propertaddress
-- this code is saying that if a.propertyaddress is null, put the b.parcelid's propertyaddress in it
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From HousingData..NashvilleHousing a
join HousingData..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyAddress is null;

--update the table
Update a
Set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From HousingData..NashvilleHousing a
join HousingData..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyAddress is null;

-- if this shows empty, then it mean table is updated
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From HousingData..NashvilleHousing a
join HousingData..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyAddress is null;


-- Breaking Out Address into individual columns (Address, City, State)

Select PropertyAddress
From HousingData..NashvilleHousing
--Where PropertyAddress is null;
--order by ParcelID;

-- in the property address, we have the address and the city
-- there are commas between the address and the city so we will use those ","

-- we will use substring and a char index(what we are looking for , starting position of search,  specify where we are looking)

Select
Substring (PropertyAddress, 1, CHARINDEX(',', propertyaddress)) as Address
from  HousingData..NashvilleHousing;
-- we are getting , in the output and we dont want that so lets fix that

--lets fidn where the , position is
Select
Substring (PropertyAddress, 1, CHARINDEX(',', propertyaddress)) as Address,CHARINDEX(',', propertyaddress)
from  HousingData..NashvilleHousing;
-- its at 19

Select
Substring (PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
from  HousingData..NashvilleHousing;

-- now we wont start from 1 pos anymore
Select
Substring (PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as address
, Substring (PropertyAddress, CHARINDEX(',', propertyaddress)+1, LEN(PropertyAddress)) as Address
from  HousingData..NashvilleHousing;

-- we cant seperate two values from column without creating two other columns

Alter Table HousingData..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update HousingData..NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1)

Alter Table HousingData..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update HousingData..NashvilleHousing
Set PropertySplitCity = Substring (PropertyAddress, CHARINDEX(',', propertyaddress)+1, LEN(PropertyAddress))

--check
select *
from  HousingData..NashvilleHousing;

--now do the same for owner address
select OwnerAddress
from  HousingData..NashvilleHousing;

--owner address has the address, city and state

-- lets try something other than charindex. lets try parsename

select 
PARSENAME(OwnerAddress, 1)
from  HousingData..NashvilleHousing;

-- parsename is useful for period. it looks for ".", so we will replace , with .

select 
PARSENAME(replace(OwnerAddress,',' , '.'),1)
from  HousingData..NashvilleHousing;


--parsename does things backward so if you do search from 1 thats basically -1


select 
PARSENAME(replace(OwnerAddress,',' , '.'),1),
PARSENAME(replace(OwnerAddress,',' , '.'),2),
PARSENAME(replace(OwnerAddress,',' , '.'),3)
from  HousingData..NashvilleHousing;

-- as parsename reads backward so we will do 321 instead of 123
select 
PARSENAME(replace(OwnerAddress,',' , '.'),3),
PARSENAME(replace(OwnerAddress,',' , '.'),2),
PARSENAME(replace(OwnerAddress,',' , '.'),1)
from  HousingData..NashvilleHousing;


-- lets update the data


Alter Table HousingData..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update HousingData..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',' , '.'),3)

Alter Table HousingData..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update HousingData..NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',' , '.'),2)


Alter Table HousingData..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update HousingData..NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress,',' , '.'),1)

--check
select *
from  HousingData..NashvilleHousing;

-- solve the yes, no, n, y thing is soldasvacant column

select distinct(soldasvacant)
from  HousingData..NashvilleHousing;

--lets try the case statement
select soldasvacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End
from  HousingData..NashvilleHousing;


update HousingData..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End

--check
select distinct(soldasvacant), COUNT(SoldAsVacant)
from  HousingData..NashvilleHousing
group by SoldAsVacant
order by 2;


-- remove dupilcates

-- not practical to delete the data 
-- should make a temp table and put the duplicate in it

-- we will write a cte and do some windows functions to find where there are duplicate values
-- some have all the same data but the uniqueid is different
Select *, 
ROW_NUMBER() over (
partition by parcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by 
uniqueID
) row_num
from HousingData..NashvilleHousing
order by ParcelID

--put this into CTE
With RowNumCTE as (
Select *, 
ROW_NUMBER() over (
partition by parcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by 
uniqueID
) row_num
from HousingData..NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE

-- rownumcte shows all the duplicates so where the delete is written it was actually select * just changed that into delete


--put this into CTE
--With RowNumCTE as (
--Select *, 
--ROW_NUMBER() over (
--partition by parcelID,
--PropertyAddress,
--SalePrice,
--SaleDate,
--LegalReference
--order by 
--uniqueID
--) row_num
--from HousingData..NashvilleHousing
----order by ParcelID
--)
--Select *
--from RowNumCTE

-- no more duplicates

-- delete unused columns that we dont care about


select *
from HousingData..NashvilleHousing;







--get rid of unused columns
select *
from HousingData..NashvilleHousing;


alter table HousingData..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress;