/*
  Project - Data Cleaning 
  Created by - Besufkad Kassahun
*/
 Use [portfolio project]

 -- Data cleaning project

    Select      *
    From        [dbo].[dbo.nashvillehousing]

 --standardize data format

    Select      saledateconverted, convert(date,saledate )
    From        [dbo].[dbo.nashvillehousing]

    Alter table [dbo].[dbo.nashvillehousing]
          add   saledateconverted date;

    Update      [dbo].[dbo.nashvillehousing]
       Set      saledateconverted = convert(date,saledate )

 --populate property address data

    Select      *
    From        [dbo].[dbo.nashvillehousing]
    Where       [PropertyAddress] is null

 --self join 
  
    Select      a.[ParcelID],a.[PropertyAddress],b.[ParcelID],b.[PropertyAddress],
                isnull(a.[PropertyAddress], b.[PropertyAddress])
    From        [dbo].[dbo.nashvillehousing] a
    Join        [dbo].[dbo.nashvillehousing] b
      On        a.[ParcelID] = b.[ParcelID]
     And        a.[UniqueID ] <> b.[UniqueID ]
   Where        a.[PropertyAddress] is null

  Update        a
     Set        [PropertyAddress] = isnull(a.[PropertyAddress], b.[PropertyAddress])
    From        [dbo].[dbo.nashvillehousing] a
    Join        [dbo].[dbo.nashvillehousing] b
      on        a.[ParcelID] = b.[ParcelID]
     And        a.[UniqueID ] <> b.[UniqueID ]
   Where        a.[PropertyAddress] is null

 --breaking out address into individual columns (adress,city,state)

  Select        [PropertyAddress]
    From        [dbo].[dbo.nashvillehousing]

    --we use sub string and charindex for the [PropertyAddress]

  Select   
                substring([PropertyAddress], 1,CHARINDEX(',',[PropertyAddress])-1) as address,
                substring([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1, len([PropertyAddress])) as address
    From        [dbo].[dbo.nashvillehousing]

    Alter table [dbo].[dbo.nashvillehousing]
      Add       propertysplitaddress nvarchar(255);

  Update        [dbo].[dbo.nashvillehousing]
     Set        propertysplitaddress = substring([PropertyAddress], 1,CHARINDEX(',',[PropertyAddress])-1)

   Alter table  [dbo].[dbo.nashvillehousing]
     Add        propertysplitcity nvarchar(255);

	 --we use sub parsename for the [OwnerAddress]

   Select 
                parsename(replace([OwnerAddress],',','.'),3),
	            parsename(replace([OwnerAddress],',','.'),2),
	            parsename(replace([OwnerAddress],',','.'),1)
     From       [dbo].[dbo.nashvillehousing]

    Alter table [dbo].[dbo.nashvillehousing]
      Add       ownersplitaddress nvarchar(255);

    Update      [dbo].[dbo.nashvillehousing]
       Set      ownersplitaddress = parsename(replace([OwnerAddress],',','.'),3)

     Alter table[dbo].[dbo.nashvillehousing]
      Add       ownersplitcity nvarchar(255);

    Update      [dbo].[dbo.nashvillehousing]
       Set      ownersplitcity = parsename(replace([OwnerAddress],',','.'),2)

     Alter table[dbo].[dbo.nashvillehousing]
       Add      ownersplitstate nvarchar(255);

    Update      [dbo].[dbo.nashvillehousing]
       Set      ownersplitstate = parsename(replace([OwnerAddress],',','.'),1)



 -- change Y and N to Yes and No in "solid as vacant" field

    Select         [SoldAsVacant],
      Case when    [SoldAsVacant]= 'y'then 'yes'
           when    [SoldAsVacant]= 'n' then 'no'
		   else    [SoldAsVacant]
	  End
      From         [dbo].[dbo.nashvillehousing]

    Update         [dbo].[dbo.nashvillehousing]
       set         [SoldAsVacant] = case when [SoldAsVacant]= 'y'then 'yes'
      when         [SoldAsVacant] = 'n' then 'no'
      else         [SoldAsVacant]
	end

-- Delete unused columns  

     Alter table   [dbo].[dbo.nashvillehousing]
     Drop column   [OwnerAddress],[TaxDistrict],[PropertyAddress],[SaleDate]



     Alter table   [dbo].[dbo.nashvillehousing]
     Drop column   [SaleDate]

 -- End 
