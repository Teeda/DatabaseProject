﻿USE TermProject
GO

---
---Customer Requirements
---
CREATE PROCEDURE AddCustomer
/*
Procedure Description:	Allows the creation of a customer with the minimum required data
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/
	@UserName nvarchar(25),		--A screen name for the customer
	@FirstName nvarchar(25),
	@LastName nvarchar(50),
	@Password nvarchar(20),
	@CustomerID int  OUTPUT	--An output of the CustomerID created
AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
		BEGIN TRAN
			Insert Into Customer(UserName, FirstName, LastName, Password)
				values (@UserName, @FirstName, @LastName, @Password)
			SELECT @CustomerID = SCOPE_IDENTITY()
			set @Return = 0
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK
		Set @Return = -1
	END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE AddCustomerExtended
/*
Procedure Description:	Allows the creation of a customer with the all required and optional data
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/
 	@UserName nvarchar(25),		--A screen name for the customer
	@FirstName nvarchar(25), 
	@LastName nvarchar(50), 
	@StreetNumber int = null,			--Optional
	@StreetName nvarchar(50) = null,	--Optional
	@StreetType nvarchar(20) = null,	--Optional, Eg. Crescent, Street, etc
	@City nvarchar(50) = null,			--Optional
	@Province nvarchar(50) = null,		--Optional
	@Country nvarchar(50) = null,		--Optional
	@PostalCode nvarchar(9) = null,		--Optional, supporting Postal and ZipCodes, including Zip+4 add on codes 
	@HomeEmail nvarchar(50) = null,		--Optional
	@WorkEmail nvarchar(50) = null,		--Optional
	@OtherEmail nvarchar(50) = null,	--Optional
	@Password nvarchar(20),
	@CustomerID int  OUTPUT	--An output of the CustomerID created

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
		BEGIN TRAN
			Insert Into Customer(UserName, FirstName, LastName,StreetNumber, StreetName, StreetType, City, Province, Country, PostalCode, Password)
				values (@UserName, @FirstName, @LastName,@StreetNumber, @StreetName, @StreetType, @City, @Province, @Country, @PostalCode, @Password)
			SELECT @CustomerID = SCOPE_IDENTITY()
			IF @HomeEmail is not null
			BEGIN	
				Insert Into CustomerEmail(CustomerID, Email, EmailType)
				values (@CustomerID, @HomeEmail, 'Home')
			END

			IF @WorkEmail is not null
			BEGIN	
				Insert Into CustomerEmail(CustomerID, Email, EmailType)
				values (@CustomerID, @WorkEmail, 'Work')
			END

			IF @OtherEmail is not null
			BEGIN	
				Insert Into CustomerEmail(CustomerID, Email, EmailType)
				values (@CustomerID, @OtherEmail, 'Other')
			END

			set @Return = 0
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK
		Set @Return = -1
	END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE UpdateCustomer
/*
Procedure Description:	Allows an existing customer to be updated
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/
	@CustomerID int,			--The customer to update
	@UserName nvarchar(25),		--New value for record
	@FirstName nvarchar(25),	--New value for record
	@LastName nvarchar(50),		--New value for record
	@StreetNumber int,			--New value for record
	@StreetName nvarchar(50),	--New value for record
	@StreetType nvarchar(20),	--New value for record
	@City nvarchar(50),			--New value for record
	@Province nvarchar(50),		--New value for record
	@Country nvarchar(50),		--New value for record
	@PostalCode nvarchar(9),	--New value for record
	@HomeEmail nvarchar(50),	--New value for record
	@WorkEmail nvarchar(50),	--New value for record
	@OtherEmail nvarchar(50)	--New value for record

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				update Customer
				set UserName = @UserName, FirstName = @FirstName, LastName = @LastName, StreetNumber = @StreetNumber, StreetName = @StreetName, StreetType = @StreetType, City = @City,
				Province = @Province, Country = @Country, PostalCode = @PostalCode where CustomerID = @CustomerID;

				update CustomerEmail set Email = @HomeEmail where CustomerID = @CustomerID and EmailType = 'Home';
				update CustomerEmail set Email = @WorkEmail where CustomerID = @CustomerID and EmailType = 'Work';
				update CustomerEmail set Email = @OtherEmail where CustomerID = @CustomerID and EmailType = 'Other';

			set @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE DeleteCustomer
/*
Procedure Description:	Allows an existing customer to be deleted if they have no Invoices for them
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/	
	@CustomerID int	--The customer to delete

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				declare @count int = 0
				select @count = count(InvoiceID) from Invoice where CustomerID = @CustomerID
				IF @count = 0
				BEGIN
					delete from Customer where CustomerID = @CustomerID;
					delete from CustomerEmail where CustomerID = @CustomerID;
				END
				SET  @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE ChangePassword
/*
Procedure Description:	Allows an existing customer to change their password if the current password is correct, and NewPassword1 is equal to newPassword2
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/	
	@CustomerID int,				--The customer to update
	@CurrentPassword nvarchar(20),	--The current password
	@NewPassword1 nvarchar(20),		--The first attempt for the new password
	@NewPassword2 nvarchar(20)		--The second attempt for the new password

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				declare @passoword nvarchar(20)
				select @passoword = Password from Customer where CustomerID = @CustomerID 
				IF @NewPassword1 <> @NewPassword2 or @passoword <> @CurrentPassword
				BEGIN
					Set @Return = -1
				END 
				ELSE
				BEGIN
					update Customer set Password = @NewPassword1 where CustomerID = @CustomerID
				END
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetCustomerByID
/*
Procedure Descriptio:	Allows existing customer information to be retrieved
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/
 	@CustomerID int,					--The customer to retrieve
	@UserName nvarchar(25)  OUTPUT,		--The value for record
	@FirstName nvarchar(25)  OUTPUT,	--The value for record
	@LastName nvarchar(50)  OUTPUT,		--The value for record
	@StreetNumber int  OUTPUT,			--The value for record
	@StreetName nvarchar(50)  OUTPUT,	--The value for record
	@StreetType nvarchar(20)  OUTPUT,	--The value for record
	@City nvarchar(50)  OUTPUT,			--The value for record
	@Province nvarchar(50)  OUTPUT,		--The value for record
	@Country nvarchar(50)  OUTPUT,		--The value for record
	@PostalCode nvarchar(9)  OUTPUT,	--The value for record
	@HomeEmail nvarchar(50)  OUTPUT,	--The value for record
	@WorkEmail nvarchar(50)  OUTPUT,	--The value for record
	@OtherEmail nvarchar(50)  OUTPUT	--The value for record

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
		BEGIN TRAN
			select @UserName = UserName, @FirstName=FirstName, @LastName=LastName, @StreetNumber=StreetNumber, @StreetName=StreetName, @StreetType=StreetType,
			@City=City, @Province=Province, @Country=Country, @PostalCode=PostalCode
			from Customer where CustomerID = @CustomerID

			select @HomeEmail = Email from CustomerEmail where EmailType = 'Home' and CustomerID = @CustomerID
			select @WorkEmail = Email from CustomerEmail where EmailType = 'Work' and CustomerID = @CustomerID
			select @OtherEmail = Email from CustomerEmail where EmailType = 'Other' and CustomerID = @CustomerID
			set @Return = 0
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK
		Set @Return = -1
	END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetCustomerList
/*
Procedure Description:	Get a list of customers based on a set of criteria, where all of the search criteria must be satisfied
Return Value			0 for success
						-1 for any error
Dataset Returned		Yes		Returns basic customer information in a format to put in a grid
	CustomerID	
	UserName
	CustomerName	A combination of FirstName and LastName with appropriate spaces
	Address			A combination of all of the address fields together with appropriate 
					spaces and commas, including:
					StreetNumber
					StreetName
					StreetType
					City
					Province
					Country
					PostalCode
*/	
	@SearchFirstName nvarchar(25) = null,	--Search criteria, parameter default should be NULL or empty string
	@SearchLastName nvarchar(50) = null,	--Search criteria, parameter default should be NULL or empty string
	@SearchCity nvarchar(50) = null,		--Search criteria, parameter default should be NULL or empty string
	@SearchProvince nvarchar(50) = null,	--Search criteria, parameter default should be NULL or empty string
	@SearchCountry nvarchar(50) = null	--Search criteria, parameter default should be NULL or empty string

/* HINT:for the WHERE condition you will want something like the following that checks the optional to see if they are filled in:
WHERE (@SearchFirstName is null or FirstName like ‘%’ + @SearchFirstName + ‘%’), --
	@AND (@SearchLastName is null or LastName like ‘%’ + @SearchLastName + ‘%’), --
	@AND …

This assumes you set the default value for the parameter as @SearchFirstName nvarchar(25), -- = NULL, as well as all the other search criteria.  
If you use a default of empty string, @FirstName nvarchar(25), -- = ‘’, then you will need to modify accordingly.
*/


AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				select CustomerID, UserName, CONCAT(FirstName, ' ', LastName) AS CustomerName, CONCAT(StreetNumber, ' ' + StreetName, ' ', StreetType, ', ', City, ', ', Province, ', ', Country, ' ', PostalCode) AS Address from Customer
				where (@SearchFirstName is null or FirstName like '%' + @SearchFirstName + '%') and (@SearchLastName is null or LastName like '%' + @SearchLastName + '%')
				and (@SearchCity is null or City like '%' + @SearchCity + '%') and (@SearchProvince is null or Province like '%' + @SearchProvince + '%')
				and (@SearchCountry is null or Country like '%' + @SearchCountry + '%')
				set @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


--- 
---Supplier Requirements
---
CREATE PROCEDURE AddSupplier
/*
Procedure Description:	Allows the creation of a Supplier with the all required and optional data
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/	
	@SupplierName nvarchar(120),--Company name of the Supplier
	@FirstName nvarchar(25),	--Contact first name for the supplier
	@LastName nvarchar(50),		--Contact last name for the supplier
	@StreetNumber int = null,			--Optional
	@StreetName nvarchar(50) = null,	--Optional
	@StreetType nvarchar(20) = null,	--Optional, Eg. Crescent, Street, etc
	@City nvarchar(50) = null,			--Optional
	@Province nvarchar(50) = null,		--Optional
	@Country nvarchar(50) = null,		--Optional
	@PostalCode nvarchar(9) = null,		--Optional, supporting Postal and ZipCodes, including Zip+4 add on codes 
	@HomeEmail nvarchar(50) = null,		--Optional
	@WorkEmail nvarchar(50) = null,		--Optional
	@OtherEmail nvarchar(50) = null,	--Optional
	@SupplierID int  OUTPUT	--An output of the SupplierID created

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE UpdateSupplier
/*
Procedure Description:	Allows an existing Supplier to be updated
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/	
	@SupplierID int,			--The Supplier to update
	@SupplierName nvarchar(120),--New value for record
	@FirstName nvarchar(25),	--New value for record
	@LastName nvarchar(50),		--New value for record
	@StreetNumber int,			--New value for record
	@StreetName nvarchar(50),	--New value for record
	@StreetType nvarchar(20),	--New value for record
	@City nvarchar(50),			--New value for record
	@Province nvarchar(50),		--New value for record
	@Country nvarchar(50),		--New value for record
	@PostalCode nvarchar(9),	--New value for record
	@HomeEmail nvarchar(50),	--New value for record
	@WorkEmail nvarchar(50),	--New value for record
	@OtherEmail nvarchar(50)	--New value for record

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE DeleteSupplier
/*
Procedure Description:	Allows an existing Supplier to be deleted if they have no Purchase Orders for them
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/	
	@SupplierID int		--The Supplier to delete

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetSupplierByID
/*
Procedure Description:	Allows an existing Supplier data to be retrieved
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/	
	@SupplierID int,					--The Supplier to retrieve
	@SupplierName nvarchar(120)  OUTPUT,--The value for record
	@FirstName nvarchar(25)  OUTPUT,	--The value for record
	@LastName nvarchar(50)  OUTPUT,		--The value for record
	@StreetNumber int  OUTPUT,			--The value for record
	@StreetName nvarchar(50)  OUTPUT,	--The value for record
	@StreetType nvarchar(20)  OUTPUT,	--The value for record
	@City nvarchar(50)  OUTPUT,			--The value for record
	@Province nvarchar(50)  OUTPUT,		--The value for record
	@Country nvarchar(50)  OUTPUT,		--The value for record
	@PostalCode nvarchar(9)  OUTPUT,	--The value for record
	@HomeEmail nvarchar(50)  OUTPUT,	--The value for record
	@WorkEmail nvarchar(50)  OUTPUT,	--The value for record
	@OtherEmail nvarchar(50)  OUTPUT	--The value for record

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetSupplierList
/*
Procedure Description:	Get a list of Suppliers based on a set of criteria, where all of the search criteria must be satisfied
Return Value			0 for success
						-1 for any error
Dataset Returned		Yes		Returns basic Supplier information in a format to put in a grid
	SupplierID
	UserName
	SupplierName	--A combination of FirstName and LastName with appropriate spaces
	Address			--A combination of all of the address fields together with appropriate spaces and commas, including:
						StreetNumber
						StreetName
						StreetType
						City
						Province
						Country
						PostalCode
 */	
	@SearchSupplierName nvarchar(25),	--Search criteria, parameter default should be NULL or empty string
	@SearchCity nvarchar(50),			--Search criteria, parameter default should be NULL or empty string
	@SearchProvince nvarchar(50),		--Search criteria, parameter default should be NULL or empty string
	@SearchCountry nvarchar(50)			--Search criteria, parameter default should be NULL or empty string
--HINT: see hint for GetCustomerList

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO

--- 
---Product Requirements
---
CREATE PROCEDURE AddProduct
/*
Procedure Description:	Adds a new product to the system
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/
	@ProductName nvarchar(25),
	@ProductDescription nvarchar(250),
	@SKU nvarchar(12),
	@Price money,
	@ProductID int OUTPUT	--The ID of the product just added

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				INSERT INTO Product(ProductName, ProductDescription, SKU, Price)
				VALUES (@ProductName, @ProductDescription, @SKU, @Price)
				SELECT @ProductID = SCOPE_IDENTITY()
				SET @Return = 0	
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE UpdateProduct
/*
Procedure Description:	Updates an existing product in the system
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/
 	@ProductID int,		--The ID of the product to edit
	@ProductName nvarchar(25),
	@ProductDescription nvarchar(250),
	@SKU nvarchar(12),
	@Price money

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				UPDATE Product
				SET ProductName = @ProductName, ProductDescription = @ProductDescription, 
					SKU = @SKU, Price = @Price
				WHERE ProductID = @ProductID	
				SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE DeleteProduct
/*
Procedure Description:	Allows an existing product to be deleted if there are no Invoices for it
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/	
	@ProductID int		--The product to delete

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				DELETE FROM Product
				WHERE ProductID = @ProductID	
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetProductByID
/*
Procedure Description:	Returns information about a specific product in the system
Return Value			0 for success
						-1 for any error
Dataset Returned		No
*/
	@ProductID int,								--The ID of the product to return
	@ProductName nvarchar(25)  OUTPUT,			--The value for record
	@ProductDescription nvarchar(250)  OUTPUT,	--The value for record
	@SKU nvarchar(12)  OUTPUT,					--The value for record
	@Price money OUTPUT							--The value for record

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				SELECT @ProductName = ProductName, @ProductDescription = ProductDescription, @SKU = SKU, @Price = Price
				FROM Product
				WHERE ProductID = @ProductID	
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetProductList
/*
Procedure Description:	Get a list of products based on a set of criteria, where all of the search criteria must be satisfied
Return Value			0 for success
						-1 for any error
Dataset Returned		Yes		Returns basic product information in a format to put in a grid
	ProductID
	ProductName
	SKU
	ProductDescription
	Price
 */	
	@SearchProductName nvarchar(25) = NULL,		--Search criteria, parameter default should be NULL or empty string
	@SearchProductDescription nvarchar(250) = NULL	--Search criteria, parameter default should be NULL or empty string
--HINT: see hint for GetCustomerList.

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				SELECT ProductID, ProductName, SKU, ProductDescription, Price
				FROM Product
				WHERE (@SearchProductName IS NULL OR ProductName LIKE '%' + @SearchProductName + '%')
					AND (@SearchProductDescription IS NULL OR ProductDescription LIKE '%' + @SearchProductDescription + '%')	
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE UpdateQuantityOnHand
/*
Procedure Description:	Updates an existing product in the system to manually override the quantity of products available.  This could happen from a manual inventory count, where the actual inventory does not match the inventory that the system indicates there should be.
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */
 	@ProductID int,		--The ID of the product to edit
	@QuantityOnHand int,--The new value for the row
	@Price money

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				UPDATE Product
				SET QuantityOnHand = @QuantityOnHand, Price = @Price
				WHERE ProductID = @ProductID	
				SET @Return = 0				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetProductBackOrderList
/*
Procedure Description:	Get a list of products that have a negative quantity, indicating that more products have been sold than actually exist in the store.
Return Value			0 for success
						-1 for any error
Dataset Returned		Yes		Returns basic product information in a format to put in a grid
	ProductID
	ProductName
	QuantityOnHand
*/
--no parameters

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				SELECT ProductID, ProductName, QuantityOnHand
				FROM Product
				WHERE QuantityOnHand < 0	
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


--- 
---Invoice Requirements
---
CREATE PROCEDURE	AddInvoice
/* Procedure Description	Add the basic header information for an invoice
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
	@InvoiceDate datetime,	
	@CustomerID int, --	The customer for the invoice
	@InvoiceID int OUTPUT --	The InvoiceID for the created invoice

AS
BEGIN
	    SET NOCOUNT ON;

	    declare @Return int = 0
	    BEGIN TRY
			BEGIN TRAN
				INSERT into Invoice (InvoiceDate, CustomerID)
					values (@InvoiceDate, @CustomerID)
				SELECT @InvoiceID = SCOPE_IDENTITY()
                SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	

	RETURN @Return
END
GO

CREATE PROCEDURE	AddInvoiceDetail
/* Procedure Description	Add a line item to the invoice.  Each invoice can have any number of InvoiceDetails.  
Each invoice can only list a particular product once, multiple invoice details for a product are not allowed.
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
	@InvoiceID int, --	The invoice to associate the invoice detail line item with
	@ProductID int, --	The product being purchased
	@Quantity int, --	The number of products being purchased
	@InvoiceDetailID int OUTPUT --	 The ID for the line item just created

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
		BEGIN TRY
			BEGIN TRAN
				INSERT into InvoiceDetail (InvoiceID, ProductID, Quantity)
					values (@InvoiceID, @ProductID, @Quantity)
					SELECT InvoiceDetailID from InvoiceDetail
						inner join Invoice
						on Invoice.InvoiceID = InvoiceDetail.InvoiceID					
					SELECT @InvoiceDetailID = SCOPE_IDENTITY()
                    SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	

	RETURN @Return
END
GO

CREATE PROCEDURE CommitInvoice
/* Procedure Description	Locks the invoice so that it can no longer be edited, 
and subtracts the updates the QuantityOnHand for each Product included on the invoice 
details for the particular invoice.
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	

    @InvoiceID int --	The invoice to commit

AS
BEGIN
	SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	declare @Return int = 0
		BEGIN TRY
			BEGIN TRAN
                UPDATE Product 
					Set Product.QuantityOnHand = Product.QuantityOnHand - InvoiceDetail.Quantity
					From Product
					inner join InvoiceDetail
					on Product.ProductID = InvoiceDetail.ProductID
					inner join Invoice
					on InvoiceDetail.InvoiceID = Invoice.InvoiceID
					Where (Product.ProductID = InvoiceDetail.ProductID) and ( Invoice.InvoiceID = @InvoiceID)
				SET @Return = 0				 
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	

	RETURN @Return
END
GO

CREATE PROCEDURE	UpdateInvoice
/* Procedure Description	Update the basic header information for an existing invoice
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
    @InvoiceID int, --	The invoice to update
	@InvoiceDate datetime,	
	@CustomerID int --	The customer for the invoice

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN TRAN
                UPDATE Invoice 
                SET InvoiceDate = @InvoiceDate, CustomerID = @CustomerID
                WHERE InvoiceID = @InvoiceID
				SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO
CREATE PROCEDURE	UpdateInvoiceDetail
/* Procedure Description	Update an existing line item to the invoice.  Each invoice can have any number of InvoiceDetails.  Each invoice can only list a particular product once, multiple invoice details for a product are not allowed.
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
    @InvoiceDetailID int, --	The invoice detail line item to update
	@ProductID int, --	The product being purchased
	@Quantity int --	The number of products being purchased

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN TRAN
                UPDATE InvoiceDetail
                SET  ProductID = @ProductID, Quantity = @Quantity
                FROM InvoiceDetail
                    inner join Invoice
                        on Invoice.InvoiceID = InvoiceDetail.InvoiceID
				Where InvoiceDetailID = @InvoiceDetailID
				SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO

CREATE PROCEDURE	DeleteInvoice
/* Procedure Description	Allows an existing invoice to be deleted only if it has not been committed
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
    @InvoiceID int --	The invoice to delete

AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN TRAN
                declare @count int = 0
                select @count = count(InvoiceID) from Invoice 
                where InvoiceID = @InvoiceID
                IF @count = 0
                    BEGIN
                        delete from Invoice where InvoiceID = @InvoiceID;
                    END
                SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO

CREATE PROCEDURE	GetInvoiceByID
/* Procedure Description	Get the basic header information for an existing invoice
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
    @InvoiceID int, --	The invoice to get
	@InvoiceDate datetime OUTPUT,	--The value for the record
	@CustomerID int OUTPUT --	The value for the record

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN TRAN
                SELECT @CustomerID = CustomerID, @InvoiceDate = InvoiceDate
                FROM Invoice WHERE InvoiceID = @InvoiceID
                SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO
CREATE PROCEDURE	GetInvoiceDetailByID
/* Procedure Description	Get the information about a particular Invoice Detail
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
    @InvoiceDetailID int, --	The invoice detail line item to get
	@ProductID int OUTPUT, --	The value for the record
	@Quantity int OUTPUT --	The value for the record


AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN TRAN
                SELECT @ProductID = ProductID, @Quantity = Quantity
                FROM InvoiceDetail WHERE InvoiceDetailID = @InvoiceDetailID
                SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO

CREATE PROCEDURE	GetInvoiceList
/* Procedure Description	Get a list of invoices based on a set of criteria, 
where all of the search criteria must be satisfied
Return Value	0 for success
-1 for any error
Dataset Returned	Yes 	Returns basic invoice information in a format to put in a grid
	InvoiceID	
	InvoiceDate	
	Customer	A combination of @FirstName and @LastName with appropriate spaces
	InvoiceAmount	The total amount of the invoice
	PaymentAmount	The total of payments for the invoice
	AmountOwing	The amount still owing for the invoice
Parameters */	
    @SearchInvoiceID int, -- 	Search criteria, parameter default should be NULL or empty string
	@SearchCustomerID int --	Search criteria, parameter default should be NULL or empty string
                     
AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN TRAN
                SELECT Invoice.InvoiceID, InvoiceDate, PaymentAmount, (Product.Price * InvoiceDetail.Quantity) as InvoiceAmount, 
				  ((Product.Price * InvoiceDetail.Quantity) - PaymentAmount) as AmountOwing from Invoice
				Inner join InvoiceDetail 
					on InvoiceDetail.InvoiceID = Invoice.InvoiceID
				Inner join Payment
					on Payment.InvoiceID = Invoice.InvoiceID
				Inner join Product
					on Product.ProductID = InvoiceDetail.ProductID
                Inner join Customer
                    on Customer.CustomerID = Invoice.CustomerID
                    SELECT CONCAT(FirstName, ' ', LastName) AS Customer
					FROM Customer
                WHERE (@SearchInvoiceID is NULL or @SearchInvoiceID like '%') and 
                (@SearchCustomerID is NULL or CustomerID like '%')
                SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO
CREATE PROCEDURE	GetInvoiceDetailList
/* Procedure Description	Get a list of invoice detail information for a particular invoice
Return Value	0 for success
-1 for any error
Dataset Returned	Yes	
	InvoiceDetailID 	The invoice detail line item ID
	InvoiceID	The invoice the detail belongs to
	ProductName	The product being purchased
	Quantity 	The number of products being purchased
Parameters */	
    @SearchInvoiceID int --	Criteria to indicate the InvoiceID to return all invoice detail for

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN TRAN
                SELECT InvoiceDetailID,  InvoiceID, ProductName, Quantity FROM InvoiceDetail
				inner join Product
					on Product.ProductID = InvoiceDetail.ProductID
                WHERE (@SearchInvoiceID is NULL or InvoiceID like '%')
                SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO

CREATE PROCEDURE	GetUnpaidInvoiceList
/* Procedure Description	Get a list of invoices based on a set of criteria, 
where all of the search criteria must be satisfied AND the amount owing is greater than $0
Return Value	0 for success
-1 for any error
Dataset Returned	Yes 	Returns basic invoice information in a format to put in a grid
	InvoiceID	
	InvoiceDate	
	Customer	A combination of @FirstName and @LastName with appropriate spaces
	InvoiceAmount	The total amount of the invoice
	PaymentAmount	The total of payments for the invoice
	AmountOwing	The amount still owing for the invoice
Parameters */	
    @SearchCustomerID int = null --	Search criteria, parameter default should be NULL or empty string
                
AS
BEGIN
	SET NOCOUNT ON;
	declare @Return int = 0
	BEGIN TRY
		BEGIN TRAN
		
			SELECT	Invoice.InvoiceID,
					Invoice.InvoiceDate,
					CONCAT(FirstName, ' ', LastName) AS Customer,
					SUM(Product.Price * InvoiceDetail.Quantity) As InvoiceAmount,
					PaymentAmount,
					SUM(Product.Price * InvoiceDetail.Quantity)-PaymentAmount AS AmountOwing 				
			FROM Invoice
				LEFT JOIN Customer ON Customer.CustomerID = Invoice.CustomerID
				LEFT JOIN InvoiceDetail on Invoice.InvoiceID = InvoiceDetail.InvoiceID
				LEFT JOIN Product on InvoiceDetail.ProductID = Product.ProductID
				LEFT JOIN Payment on Invoice.InvoiceID = Payment.InvoiceID
			WHERE Customer.CustomerID = @SearchCustomerID or @SearchCustomerID is null
			GROUP BY Invoice.InvoiceID,InvoiceDate,CONCAT(FirstName, ' ', LastName),PaymentAmount
			HAVING SUM(Product.Price * InvoiceDetail.Quantity)-PaymentAmount>0
            SET @Return = 0
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK
			Set @Return = -1
		END CATCH
	RETURN @Return
END
GO

CREATE PROCEDURE	ReturnInvoice
/* Procedure Description	Creates a new invoice based on an existing committed invoice.  
The invoice date should be the current date, and all other information from the Invoice and 
InvoiceDetail should be the same except:
•	that all the quantities should be negative, indicating that the product(s), -- have been returned
•	the newly created invoice should not be committed, so that it is still available to edit
Return Value	0 for success
-1 for any error
Dataset Returned	No	
Parameters */	
    @ReturnInvoiceID int, --	The InvoiceID of the invoice to return
	@NewInvoiceID int OUTPUT --	The InvoiceID of the newly created invoice

AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	declare @Return int = 0
	IF @Return = 0
		BEGIN
		BEGIN TRY
			BEGIN
			BEGIN TRAN
				declare @InvoiceID int = 0
				select @InvoiceID = InvoiceID from Invoice where InvoiceID = @ReturnInvoiceID
				IF @InvoiceID <> 0
				BEGIN
					insert into Invoice (CustomerID, InvoiceDate) (select CustomerID, CURRENT_TIMESTAMP from Invoice where InvoiceID = @ReturnInvoiceID)
					SELECT @NewInvoiceID = SCOPE_IDENTITY()
					insert into InvoiceDetail (InvoiceID, ProductID, Quantity) select @NewInvoiceID, ProductID, Quantity * -1 
					from InvoiceDetail where InvoiceID = @ReturnInvoiceID
				END
				ELSE set @Return = -1
			END 
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	END

	RETURN @Return
END
GO

---
---Purchase Order Requirements
---
CREATE PROCEDURE AddPurchaseOrder
/*
Procedure Description:	Add the basic header information for a PurchaseOrder
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PurchaseOrderDate datetime,
	@SupplierID int,				--The supplier for the PurchaseOrder
	@PurchaseOrderID int  OUTPUT	--The PurchaseOrderID for the created PurchaseOrder

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE AddPurchaseOrderDetail
/*
Procedure Description:	Add a line item to the PurchaseOrder.  Each PurchaseOrder can have any number of PurchaseOrderDetails.  Each PurchaseOrder can only list a particular product once, multiple PurchaseOrder details for a product are not allowed.
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */
 	@PurchaseOrderID int,	--The PurchaseOrder to associate the PurchaseOrder detail line item with
	@ProductID int,			--The product being purchased
	@Quantity int,			--The number of products being purchased
	@PurchaseOrderDetailID int  OUTPUT --The ID for the line item just created


AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE CommitPurchaseOrder
/*
Procedure Description:	Locks the PurchaseOrder so that it can no longer be edited, and subtracts the updates the QuantityOnHand for each Product included on the PurchaseOrder details for the particular PurchaseOrder.
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PurchaseOrderID int  --The PurchaseOrder to commit

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE UpdatePurchaseOrder
/*
Procedure Description:	Update the basic header information for an existing PurchaseOrder
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PurchaseOrderID int,		--The PurchaseOrder to update
	@PurchaseOrderDate datetime,
	@SupplierID int			--The supplier for the PurchaseOrder

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE UpdatePurchaseOrderDetail
/*
Procedure Description:	Update an existing line item to the PurchaseOrder.  Each PurchaseOrder can have any number of PurchaseOrderDetails.  Each PurchaseOrder can only list a particular product once, multiple PurchaseOrder details for a product are not allowed.
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PurchaseOrderDetailID int, --The PurchaseOrder detail line item to update
	@ProductID int,				--The product being purchased
	@Quantity int				--The number of products being purchased

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE DeletePurchaseOrder
/*
Procedure Description:	Allows an existing PurchaseOrder to be deleted only if it has not been committed
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PurchaseOrderID int	 --The PurchaseOrder to delete


AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetPurchaseOrderByID
/*
Procedure Description:	Get the basic header information for an existing PurchaseOrder
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PurchaseOrderID int,  --The PurchaseOrder to get
	@PurchaseOrderDate datetime OUTPUT,	--The value for the record
	@SupplierID int  OUTPUT --The value for the record

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetPurchaseOrderDetailByID
/*
Procedure Description:	Get the information about a particular PurchaseOrder Detail
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */
 	@PurchaseOrderDetailID int,		--The PurchaseOrder detail line item to get
	@ProductID int  OUTPUT,			--The value for the record
	@Quantity int  OUTPUT			--The value for the record


AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetPurchaseOrderList
/*
Procedure Description:	Get a list of PurchaseOrders based on a set of criteria, where all of the search criteria must be satisfied
Return Value			0 for success
						-1 for any error
Dataset Returned		Yes		Returns basic PurchaseOrder information in a format to put in a grid

	PurchaseOrderID
	PurchaseOrderDate
	SupplierName
	PurchaseOrderAmount			--The total amount of the PurchaseOrder
	PaymentAmount				--The total of payments for the PurchaseOrder
	AmountOwing					--The amount still owing for the PurchaseOrder
*/
	@SearchPurchaseOrderID int,	--Search criteria, parameter default should be NULL or empty string
	@SearchSupplierID int		--Search criteria, parameter default should be NULL or empty string
--HINT: see hint for GetCustomerList.

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetUnpaidPurchaseOrderList
/*
Procedure Description:	Get a list of PurchaseOrders based on a set of criteria, where all of the search criteria must be satisfied AND the amount owing is greater than $0
Return Valu				0 for success
						-1 for any error
Dataset Returned		Yes		Returns basic PurchaseOrder information in a format to put in a grid
	PurchaseOrderID	
	PurchaseOrderDate	
	SupplierName	
	PurchaseOrderAmount	--The total amount of the PurchaseOrder
	PaymentAmount		--The total of payments for the PurchaseOrder
	AmountOwing			--The amount still owing for the PurchaseOrder
*/	
	 @SearchSupplierID int  --	@Search criteria, parameter default should be NULL or empty string
--HINT: see hint for GetCustomerList.


AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE ReturnPurchaseOrder
/*
Procedure Description:	Creates a new PurchaseOrder based on an existing committed PurchaseOrder.
						The PurchaseOrder date should be the current date, and all other information 
						from the PurchaseOrder and PurchaseOrderDetail should be the same except:
						•	that all the quantities should be negative, indicating that the product(s) have been returned
						•	the newly created PurchaseOrder should not be committed, so that it is still available to edit
Return Value			0 for success
						-1 for any error
Dataset Returned		NO
 */	
	@ReturnPurchaseOrderID int,  --The PurchaseOrderID of the PurchaseOrder to return
	@NewPurchaseOrderID int  OUTPUT --The PurchaseOrderID of the newly created PurchaseOrder

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO

--- 
---Payment Requirements
---
CREATE PROCEDURE AddPayment
/*
Procedure Description:	Adds a new Payment to an Invoice.  Note that multiple payments to an invoice are allowed.
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */
	@InvoiceID int,  --The invoice to apply the payment to
	@PaymentAmount money,	--The amount paid
	@PaymentDate datetime,	--The date of the payment
	@PaymentReference nvarchar(20), --A reference for the payment, could be a Cheque number, credit card type, PayPal reference, etc
	@PaymentID int  OUTPUT --The ID of the Payment just added

AS
BEGIN
	SET NOCOUNT ON;
	declare @Return int = 0
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Payment(InvoiceID, PaymentAmount,PaymentDate, PaymentReference)
				VALUES(@InvoiceID,@PaymentAmount,@PaymentDate,@PaymentReference)
			SELECT @PaymentID = SCOPE_IDENTITY()
			SET @Return = 0
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK
		Set @Return = -1
	END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE UpdatePayment
/*
Procedure Description:	Updates an existing Payment in the system
Return Value		0 for success
					-1 for any error
Dataset Returned	No
 */	
	@PaymentID int,  --	The ID of the Payment to edit
	@InvoiceID int, 
	@PaymentAmount money,	
	@PaymentDate datetime,	
	@PaymentReference nvarchar(20)

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				UPDATE Payment
				SET InvoiceID = @InvoiceID, PaymentAmount = @PaymentAmount, PaymentDate = @PaymentDate, PaymentReference = @PaymentReference
				WHERE PaymentID = @PaymentID;  
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE DeletePayment
/*
Procedure Description:	Allows an existing Payment to be deleted
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PaymentID int  --	The Payment to delete

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				DELETE FROM Payment
				WHERE PaymentID = @PaymentID
				SET @Return = 0
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO


CREATE PROCEDURE GetPaymentByID
/*
Procedure Description:	Returns information about a specific Payment in the system
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
	@PaymentID int,  --The ID of the Payment to return
	@InvoiceID int  OUTPUT, --The value for record
	@PaymentAmount money OUTPUT,	--The value for record
	@PaymentDate datetime OUTPUT,	---The value for record
	@PaymentReference nvarchar(20)  OUTPUT --	The value for record

AS
BEGIN
	SET NOCOUNT ON;
	declare @Return int = 0
	BEGIN TRY
		BEGIN TRAN
			SELECT @InvoiceID = InvoiceID, @PaymentAmount = PaymentAmount, @PaymentDate = PaymentDate, @PaymentReference = PaymentReference
			FROM Payment WHERE PaymentID = @PaymentID
			SET @Return = 0
		COMMIT TRAN
	END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH
	RETURN @Return
END
GO


CREATE PROCEDURE GetPaymentList
/*
Procedure Description:	Get a list of Payments based on a set of criteria, 
						where all of the search criteria must be satisfied
Return Value			0 for success
						-1 for any error
Dataset Returned		Yes		Returns basic Payment information in a format to put in a grid
	PaymentID	
	InvoiceID	
	PaymentAmount	
	PaymentDate	
	PaymentReference	
*/
	@SearchInvoiceID int = NULL,			--Search criteria, parameter default should be NULL or empty string
	@SearchPaymentDate datetime	= NULL	--Search criteria, parameter default should be NULL or empty string
--HINT: see hint for GetCustomerList.
 

AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
		BEGIN TRAN
			SELECT PaymentID, InvoiceID, PaymentAmount, PaymentDate, PaymentReference
			FROM Payment
			WHERE (@SearchInvoiceID IS NULL OR InvoiceID = @SearchInvoiceID ) AND (@SearchPaymentDate IS NULL OR PaymentDate = @SearchPaymentDate )
			SET @Return = 0;
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK
		Set @Return = -1
	END CATCH

	RETURN @Return
END
GO


---
---Miscellaneous Requirements
---
CREATE PROCEDURE DeleteAllData
/*
Procedure Description:	Deletes all data from the database.  Note that the order of deletion must deal with any relationships.  EG. all customers cannot be deleted until all Invoices are deleted.
Return Value			0 for success
						-1 for any error
Dataset Returned		No
 */	
AS
BEGIN
	SET NOCOUNT ON;

	declare @Return int = 0
	BEGIN TRY
			BEGIN TRAN
				
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK
			Set @Return = -1
		END CATCH

	RETURN @Return
END
GO
