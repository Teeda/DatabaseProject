USE TermProject
GO

declare @PaymentID int
declare @Return int

EXEC @Return = AddPayment 
	'12345678', 
	100, 
	"2014-1-1", 
	"33AABBCC44",
	@PaymentID OUTPUT
SELECT @Return as ReturnValue,@PaymentID as PaymentID
GO
