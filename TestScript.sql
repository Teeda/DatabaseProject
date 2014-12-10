USE TermProject
GO

--Customer test script by weiwei chen
declare @CustomerID int
declare @Return int

EXEC @Return = AddCustomer
	'test',
	'test',
	'test',
	'test',
	@CustomerID  OUTPUT
select @Return as ReturnValue, @CustomerID as CustomerID
select * from Customer

EXEC @Return = AddCustomer
	NULL,
	'test2',
	'test2',
	'test2',
	@CustomerID  OUTPUT
select @Return as ReturnValue, @CustomerID as CustomerID
select * from Customer
GO
/* end test add customer */

/*
test add customer extend
*/
declare @CustomerID int
declare @Return int

EXEC @Return = AddCustomerExtended
	'testCustomerExtend',
	'firstname',
	'lastname',
	'30',
	'Ottawa',
	'Stree',
	'Kitchener',
	'Ontario',
	'Canada',
	'N2Q 2L2',
	'email1@conestogac.on.ca',
	'email2@conestogac.on.ca',
	'email3@conestogac.on.ca',
	'123',
	@CustomerID  OUTPUT
select @Return as ReturnValue, @CustomerID as CustomerID
select * from Customer


EXEC @Return = AddCustomerExtended
	'testCustomerExtend',
	'firstname2',
	'lastname2',
	'10',
	'Ottawa',
	'Stree',
	'Kitchener',
	'Ontario',
	'Canada',
	'N2Q 2L2',
	'email1@conestogac.on.ca',
	NULL,
	NULL,
	'123',
	@CustomerID  OUTPUT
select @Return as ReturnValue, @CustomerID as CustomerID
select * from Customer

GO
/* end test add customer extend*/

/* test UpdateCustomer*/
declare @Return int
EXEC @Return = UpdateCustomer
	'1',
	'testUpdateCustomer',
	'firstname2',
	'lastname2',
	'123',
	'Ottawa',
	'Stree',
	'Kitchener',
	'Ontario',
	'Canada',
	'N2Q 2L2',
	'email1@conestogac.on.ca',
	NULL,
	NULL
select @Return as ReturnValue, * from Customer where CustomerID = '1'

/* non existing customer*/
EXEC @Return = UpdateCustomer
	'200',
	'testUpdateCustomer',
	'firstname2',
	'lastname2',
	'123',
	'Ottawa',
	'Stree',
	'Kitchener',
	'Ontario',
	'Canada',
	'N2Q 2L2',
	'email1@conestogac.on.ca',
	NULL,
	NULL
select @Return as ReturnValue
select * from Customer where CustomerID = '200'
GO
/* end test UpdateCustomer*/

/* test deleteCustomer*/
declare @Return int
EXEC @Return = DeleteCustomer '3'
select @Return as ReturnValue
select * from Customer

EXEC @Return = DeleteCustomer '3'
select @Return as ReturnValue
select * from Customer
GO
/* end test deleteCustomer*/

/* test changePassword*/
declare @Return int
EXEC @Return = ChangePassword 
	'1',
	'changedPassword',
	'changedPassword',
	'changedPassword' 
select @Return as ReturnValue, * from Customer where CustomerID='1'

/* password does not match */
EXEC @Return = ChangePassword 
	'1',
	'changedPassword',
	'changedPassword3',
	'changedPassword4' 
select @Return as ReturnValue, * from Customer where CustomerID='1'
GO
/* end test changePassword*/

/* test GetCustomerByID*/
declare @Return int
declare @UserName nvarchar(25), @FirstName nvarchar(25), @LastName nvarchar(50), @StreetNumber int, @StreetName nvarchar, @StreetType nvarchar(20)
declare @City nvarchar(50), @Province nvarchar(50), @Country nvarchar(50), @PostalCode nvarchar(9), @HomeEmail nvarchar(50), @WorkEmail nvarchar(50), @OtherEmail nvarchar(50)
EXEC @Return = GetCustomerByID 
	'1',
	@UserName  OUTPUT,		--The value for record
	@FirstName OUTPUT,	--The value for record
	@LastName OUTPUT,		--The value for record
	@StreetNumber OUTPUT,			--The value for record
	@StreetName  OUTPUT,	--The value for record
	@StreetType OUTPUT,	--The value for record
	@City OUTPUT,			--The value for record
	@Province OUTPUT,		--The value for record
	@Country OUTPUT,		--The value for record
	@PostalCode OUTPUT,	--The value for record
	@HomeEmail OUTPUT,	--The value for record
	@WorkEmail OUTPUT,	--The value for record
	@OtherEmail OUTPUT
select @Return as ReturnValue, @UserName as Username, @FirstName as FirstName, @LastName as LastName, @StreetNumber as StreetNumber,
	@StreetName as StreetName, @StreetType as StreetType, @City as City, @Province as Province, @Country as Country, @PostalCode as PostalCode,
	@HomeEmail as HomeEmail, @WorkEmail as WorkEmail, @OtherEmail as OtherEmail

/* not existing customer*/
EXEC @Return = GetCustomerByID 
	'1454',
	@UserName  OUTPUT,		--The value for record
	@FirstName OUTPUT,	--The value for record
	@LastName OUTPUT,		--The value for record
	@StreetNumber OUTPUT,			--The value for record
	@StreetName  OUTPUT,	--The value for record
	@StreetType OUTPUT,	--The value for record
	@City OUTPUT,			--The value for record
	@Province OUTPUT,		--The value for record
	@Country OUTPUT,		--The value for record
	@PostalCode OUTPUT,	--The value for record
	@HomeEmail OUTPUT,	--The value for record
	@WorkEmail OUTPUT,	--The value for record
	@OtherEmail OUTPUT
select @Return as ReturnValue, @UserName as Username, @FirstName as FirstName, @LastName as LastName, @StreetNumber as StreetNumber,
	@StreetName as StreetName, @StreetType as StreetType, @City as City, @Province as Province, @Country as Country, @PostalCode as PostalCode,
	@HomeEmail as HomeEmail, @WorkEmail as WorkEmail, @OtherEmail as OtherEmail
GO
/* end test GetCustomerByID*/

/* test get customer list*/
declare @Return int
EXEC @Return = GetCustomerList
select @Return as ReturnValue
GO

--AddPayment
declare @PaymentID int
declare @Return int
EXEC @Return = AddPayment 
	12345678, 		--InvoiceID int
	100, 			--PaymentAmount money
	"2014-01-01", 	--PaymentDate datetime
	"33AABBCC44",	--PaymentReference nvarchar(20)
	@PaymentID OUTPUT
SELECT @Return as ReturnValue,@PaymentID as PaymentID
GO


--UpdatePayment
declare @Return int
EXEC @Return = UpdatePayment 
	000000000, 		--PaymentID int	The ID of the Payment to edit
	12345679,		--InvoiceID int
	100, 			--PaymentAmount money
	"2014-1-1", 	--PaymentDate datetime
	"33AABBCC44"	--PaymentReference nvarchar
SELECT @Return as ReturnValue,* from Payment
GO


--DeletePayment
declare @Return int
EXEC @Return = DeletePayment
	000000000 		--PaymentID int The ID of the Payment to dedete
SELECT @RETURN as ReturnValue
GO


--GetPaymentByID
declare @Return int
declare @InvoiceID int
declare @PaymentAmount money
declare @PaymentDate datetime
declare @PaymentReference nvarchar
EXEC @Return = GetPaymentByID
	000000000,				--PaymentID int
	@InvoiceID  OUTPUT,
	@PaymentAmount  OUTPUT,
	@PaymentDate  OUTPUT,
	@PaymentReference OUTPUT	
SELECT @Return as ReturnValue,@InvoiceID as InvoiceID,@PaymentAmount as PaymentAmount, @PaymentDate as PaymentDate,@PaymentReference as PaymentReference
GO

--GetPaymentList
declare @Return int
EXEC @Return = GetPaymentList
	0000000000,			--SearchInvoiceID
	"2014-01-01"		--SearchPaymentDate	
SELECT @Return as ReturnValue
GO

declare @Return int
EXEC @Return = GetPaymentList
SELECT @Return as ReturnValue
GO

/*Test AddInvoice */
DECLARE @InvoiceID int
DECLARE @Return int
EXEC @Return = AddInvoice
	"2011-11-11",
	1,
	@InvoiceID  OUTPUT
SELECT @Return as ReturnValue, @InvoiceID as InvoiceID
SELECT * from Invoice

EXEC @Return = AddInvoice
	"2011-11-11",
	null,
	@InvoiceID  OUTPUT
SELECT @Return as ReturnValue, @InvoiceID as InvoiceID
SELECT * from Invoice
GO

/*Test AddInvoiceDetail */
DECLARE @InvoiceDetailID int
DECLARE @Return int
EXEC @Return = AddInvoiceDetail
	1,
	1,
	1,
	@InvoiceDetailID OUTPUT
SELECT @Return as ReturnValue, @InvoiceDetailID as InvoiceDetailID
SELECT * from InvoiceDetail

EXEC @Return = AddInvoiceDetail
	0,
	null,
	1,
	@InvoiceDetailID OUTPUT
SELECT @Return as ReturnValue, @InvoiceDetailID as InvoiceDetailID
SELECT * from InvoiceDetail
GO

/*Update Invoice */
DECLARE @Return int
EXEC @Return = UpdateInvoice
	5,
	"2011-01-01",
	5
SELECT @Return as ReturnValue
SELECT * from Invoice

EXEC @Return = UpdateInvoice
	50000,
	"2016-01-01",
	1
SELECT @Return as ReturnValue
SELECT * from Invoice
GO

/*Update InvoiceDetail */
DECLARE @Return int
EXEC @Return = UpdateInvoiceDetail
	2,
	1,
	1
SELECT @Return as ReturnValue
SELECT * from InvoiceDetail

EXEC @Return = UpdateInvoiceDetail
	null,
	null,
	9
SELECT @Return as ReturnValue
SELECT * from InvoiceDetail
GO

/*Get Invoice By ID */
DECLARE @Return int
DECLARE @InvoiceDate Datetime, @CustomerID int
EXEC @Return = GetInvoiceByID
	1,
	@InvoiceDate OUTPUT,
	@CustomerID OUTPUT
SELECT @Return as ReturnValue
SELECT * from Invoice

EXEC @Return = GetInvoiceByID
	0,
	@InvoiceDate OUTPUT,
	@CustomerID OUTPUT
SELECT @Return as ReturnValue
SELECT * from Invoice
GO

/*Get InvoiceDetail by ID */
DECLARE @Return int
DECLARE @ProductID int, @Quantity int
EXEC @Return = GetInvoiceDetailByID
	1,
	@ProductID OUTPUT,
	@Quantity OUTPUT
SELECT @Return as ReturnValue
SELECT * from InvoiceDetail

EXEC @Return = GetInvoiceDetailByID
	0,
	@ProductID OUTPUT,
	@Quantity OUTPUT
SELECT @Return as ReturnValue
SELECT * from InvoiceDetail
GO

--AddPurchaseOrder
declare @PurchaseOrderID int
declare @Return int
EXEC @Return = AddPurchaseOrder
	"2014-01-01",
	0, 			
	@PurchaseOrderID OUTPUT
SELECT @Return as ReturnValue,@PurchaseOrderID as PurchaseOrderID
GO

SELECT * from PurchaseOrder

--UpdatePurchaseOrder
declare @Return int
EXEC @Return = UpdatePurchaseOrder 
	000000000, 		--PurchaseOrderID int	The ID of the PurchaseOrder to edit
	"2014-1-1", 	--PurchaseOrderDate datetime
	12345679		--PurchaseOrderID int
SELECT @Return as ReturnValue,* from PurchaseOrder
GO

--DeletePurchaseOrder
declare @Return int
EXEC @Return = DeletePurchaseOrder 
	000000000 		--PurchaseOrderID int The ID of the PurchaseOrder to dedete
SELECT @RETURN as ReturnValue
GO
