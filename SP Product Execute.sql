USE TermProject
GO

-- 1. AddProduct  --
declare @ProductID int
declare @Return int 
EXEC @Return = AddProduct 
	 'Product One',
	 'Awesone Product One',
	 'PROD12345678', 75,
	 @ProductID OUTPUT
SELECT @Return as ReturnValue, @ProductID as ProductID
SELECT * FROM Product

EXEC @Return = AddProduct 
	 'Product One',
	 'Awesone Product One',
	 'PROD12345678', price,
	 @ProductID OUTPUT

SELECT @Return as ReturnValue, @ProductID as ProductID
SELECT * FROM Product
GO
-- 2. UpdateProduct --
declare @ProductID int
declare @Return int 

EXEC @Return = UpdateProduct '5', 'new name', 'new description', 'NEWSKU 123', 80

SELECT @Return as ReturnValue

SELECT * FROM Product

-- 3. DeleteProduct --

declare @Return int
EXEC @Return = DeleteProduct '6'
SELECT @Return as ReturnValue
SELECT * FROM Product

-- 4. GetProductByID --

declare @Return int
declare @ProductName nvarchar(25)
declare	@ProductDescription nvarchar(250) 
declare	@SKU nvarchar(12)
declare	@Price money

EXEC @Return = GetProductByID 
	7,
	@ProductName OUTPUT,
	@ProductDescription OUTPUT,
	@SKU OUTPUT,
	@Price OUTPUT

SELECT @Return as ReturnValue, @ProductName as ProductName, @ProductDescription as ProductDescription, @SKU as SKU, @Price as Price
GO

-- 5. Get Product List ---

declare @Return int
EXEC @Return = GetProductList 'n', 'e' 
select @Return as ReturnValue
GO

-- 6. UpdateQuantityOnHand --
declare @Return int
EXEC @Return = UpdateQuantityOnHand
			   '5', 34, 72 
select @Return as ReturnValue, * FROM Product WHERE ProductID = 5
GO

-- 7. GetProductBackOrderList --
declare @Return int
EXEC @Return = UpdateQuantityOnHand
			   '5', -34, 72 
select @Return as ReturnValue, * FROM Product WHERE ProductID = 5
GO

declare @Return int
EXEC @Return = GetProductBackOrderList
select @Return as ReturnValue, * FROM Product WHERE QuantityOnHand < 0
GO

-- NOTES --

SELECT * FROM Product
DELETE FROM Product