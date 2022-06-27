 

USE  mydatabasename
GO

--creates a computed and persisted COLUMN for sale_item subtotal
ALTER TABLE sale_items
  ADD (qty * unit_price) AS subtotal PERSISTED
GO


 