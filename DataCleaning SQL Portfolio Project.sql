--Cleaning Data in SQL Queries
Select *
From PortfolioProject.dbo.NashvilleHausing

--Standardize Date Formate
Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHausing

Alter Table PortfolioProject.dbo.NashvilleHausing
Add SaleDateConverted Date
Update PortfolioProject.dbo.NashvilleHausing
Set SaleDateConverted=Convert(Date,SaleDate)
Alter Table PortfolioProject.dbo.NashvilleHausing
Drop Column SaleDate
Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHausing

--Populate Property Address Data
Select *
From PortfolioProject.dbo.NashvilleHausing
Where PropertyAddress is null

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHausing A
Join PortfolioProject.dbo.NashvilleHausing B
on A.ParcelID=B.ParcelID
and A.[UniqueID ]<>B.[UniqueID ]
Where A.PropertyAddress is null

Update A
Set PropertyAddress=ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHausing A
Join PortfolioProject.dbo.NashvilleHausing B
on A.ParcelID=B.ParcelID
and A.[UniqueID ]<>B.[UniqueID ]

--Breaking out PropertyAddress into individual Columns (Address, City) with Substring
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHausing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHausing

Alter Table NashvilleHausing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHausing
Set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1)

Alter Table NashvilleHausing
Add PropertySplitCity nvarchar(255)

Update NashvilleHausing
Set PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress))

--Breaking out OwnerAddress into individual Columns (Address, City, State) with Parsename
Select 
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvilleHausing

Alter Table NashvilleHausing
Add OwnerSplitAddress Nvarchar(255),
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255)

Update NashvilleHausing
Set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress, ',','.'),3),
OwnerSplitCity=PARSENAME(Replace(OwnerAddress, ',','.'),2),
OwnerSplitState=PARSENAME(Replace(OwnerAddress, ',','.'),1)

--Change Y and N to Yes and No in Sold as Vacant
Select Distinct (SoldasVacant), COUNT(SoldasVacant)
From PortfolioProject.dbo.NashvilleHausing
Group By SoldasVacant
Order By 2

Select SoldasVacant,
Case
When SoldasVacant='Y' Then 'Yes'
When SoldasVacant='N' Then 'No'
Else SoldasVacant
End
From PortfolioProject.dbo.NashvilleHausing

Update NashvilleHausing
Set SoldasVacant= Case
When SoldasVacant='Y' Then 'Yes'
When SoldasVacant='N' Then 'No'
Else SoldasVacant
End

--Remove Duplicate
With RowNumCTE as(
Select * , Row_Number() over (
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDateConverted,
			 LegalReference
			 Order By UniqueID
			 ) as Row_Num
From PortfolioProject.dbo.NashvilleHausing)

Delete
from RowNumCTE
where Row_Num>1

--Delete Unused Column
Alter Table PortfolioProject.dbo.NashvilleHausing
Drop Column PropertyAddress, OwnerAddress