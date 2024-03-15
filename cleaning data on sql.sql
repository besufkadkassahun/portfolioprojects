-- Data cleaning project

select *
from [dbo].[dbo.nashvillehousing]

--standardize data format

select saledateconverted, convert(date,saledate )
from [dbo].[dbo.nashvillehousing]

alter table [dbo].[dbo.nashvillehousing]
add saledateconverted date;

update [dbo].[dbo.nashvillehousing]
set saledateconverted = convert(date,saledate )

--populate property address data

select *
from [dbo].[dbo.nashvillehousing]
where [PropertyAddress] is null

   --self join 
select a.[ParcelID],a.[PropertyAddress],b.[ParcelID],b.[PropertyAddress],
       isnull(a.[PropertyAddress], b.[PropertyAddress])
from [dbo].[dbo.nashvillehousing] a
join [dbo].[dbo.nashvillehousing] b
   on a.[ParcelID] = b.[ParcelID]
   and a.[UniqueID ] <> b.[UniqueID ]
   where a.[PropertyAddress] is null

update a
set [PropertyAddress] = isnull(a.[PropertyAddress], b.[PropertyAddress])
    from [dbo].[dbo.nashvillehousing] a
join [dbo].[dbo.nashvillehousing] b
   on a.[ParcelID] = b.[ParcelID]
   and a.[UniqueID ] <> b.[UniqueID ]
   where a.[PropertyAddress] is null

--breaking out address into individual columns (adress,city,state)

select [PropertyAddress]
from [dbo].[dbo.nashvillehousing]

    --we use sub string and charindex
select   
   substring([PropertyAddress], 1,CHARINDEX(',',[PropertyAddress])-1) as address,
   substring([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1, len([PropertyAddress])) as address
from [dbo].[dbo.nashvillehousing]

alter table [dbo].[dbo.nashvillehousing]
add propertysplitaddress nvarchar(255);

update [dbo].[dbo.nashvillehousing]
set propertysplitaddress = substring([PropertyAddress], 1,CHARINDEX(',',[PropertyAddress])-1)

alter table [dbo].[dbo.nashvillehousing]
add propertysplitcity nvarchar(255);


select *
from [dbo].[dbo.nashvillehousing] 
