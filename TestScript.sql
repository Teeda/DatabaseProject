USE TermProject
GO

--AddPayment
declare @PaymentID int
declare @Return int

EXEC @Return = AddPayment 
	12345678, 	--InvoiceID int
	100, 			--PaymentAmount money
	"2014-1-1", 	--PaymentDate datetime
	"33AABBCC44",	--PaymentReference nvarchar(20)
	@PaymentID OUTPUT
SELECT @Return as ReturnValue,@PaymentID as PaymentID
GO


--UpdatePayment
declare @Return int

EXEC @Return = UpdatePayment 
	000000000, 		--PaymentID int
	12345679,		--InvoiceID int
	100, 			--PaymentAmount money
	"2014-1-1", 	--PaymentDate datetime
	"33AABBCC44",	--PaymentReference nvarchar
SELECT @Return as ReturnValue
GO


--DeletePayment
declare @Return int

EXEC @Return = DeletePayment
	000000000 		--PaymentID int
SELECT @RETURN as ReturnValue
GO


--GetPaymentByID
declare @Return int
declare @InvoiceID int
declare @PaymentAmount money
declare @PaymentDate datetime
declare @PaymentReference nvarchar

EXEC @Return = GetPaymentByID
	000000000,			--PaymentID int
	@Invoice int OUTPUT
	@PaymentAmount money OUTPUT
	@PaymentDate datetime OUTPUT
	@PaymentReference OUTPUT
	
SELECT @Return as ReturnValue,@InvoiceID as InvoiceID,@PaymentAmount as PaymentAmount, @PaymentDate as PaymentDate,@PaymentReference as PaymentReference
GO

--GetPaymentList
declare @Return int

EXEC @Return = GetPaymentList
	0000000000,		--SearchInvoiceID
	2014-1-1,		--SearchPaymentDate
	
SELECT @Return as ReturnValue