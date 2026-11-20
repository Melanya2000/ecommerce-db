

USE [E-Commerce];
GO
SET NOCOUNT ON;
GO

-- ---------- Reference data ----------
INSERT INTO dbo.Coupons (CouponCode, DiscountPercentage, ExpiryDate, IsActive) VALUES
    (N'CAKE20', 20, N'2026-12-31', 1),
    (N'WELCOME10', 10, N'2027-06-30', 1),
    (N'WEDDING15', 15, N'2026-12-31', 1),
    (N'SUMMER25', 25, N'2026-08-31', 1),
    (N'OLDPROMO', 30, N'2026-01-31', 0);

-- ---------- Categories ----------
SET IDENTITY_INSERT dbo.Categories ON;
INSERT INTO dbo.Categories (CategoryID, CategoryName, Description) VALUES
    (1, N'Wedding Cakes', N'Elegant cakes for your special day'),
    (2, N'Kids Cakes', N'Fun and colorful cakes for children'),
    (3, N'Birthday Cakes', N'Classic and creative birthday cakes'),
    (4, N'Pastries & Cupcakes', N'Freshly baked pastries and cupcakes'),
    (5, N'Jelly Desserts', N'Refreshing jelly-based desserts'),
    (6, N'Custom/Other Treats', N'Personalized treats for any occasion');
SET IDENTITY_INSERT dbo.Categories OFF;

-- ---------- Products ----------
-- StockQuantity here = stock BEFORE the sample orders; the order trigger reduces it
SET IDENTITY_INSERT dbo.Products ON;
INSERT INTO dbo.Products (ProductID, Name, CategoryID, Description, SKU, Price, Cost, StockQuantity, ReorderLevel, CreatedDate) VALUES
    (1, N'Classic White Tiered Cake', 1, NULL, N'WED-001', 45000, 20000, 9, 1, '2025-11-15T10:00:00'),
    (2, N'Floral Elegance Cake', 1, NULL, N'WED-002', 55000, 25000, 5, 1, '2025-11-15T10:00:00'),
    (3, N'Gold Leaf Luxury Cake', 1, NULL, N'WED-003', 75000, 35000, 2, 1, '2025-11-15T10:00:00'),
    (4, N'Rustic Wedding Cake', 1, NULL, N'WED-004', 40000, 18000, 5, 1, '2025-11-15T10:00:00'),
    (5, N'Superhero Adventure Cake', 2, NULL, N'KIDS-001', 35000, 15000, 5, 2, '2025-11-15T10:00:00'),
    (6, N'Princess Castle Cake', 2, NULL, N'KIDS-002', 38000, 16000, 5, 2, '2025-11-15T10:00:00'),
    (7, N'Classic Chocolate Birthday', 3, NULL, N'BIRTH-001', 25000, 10000, 10, 3, '2025-11-15T10:00:00'),
    (8, N'Red Velvet Celebration', 3, NULL, N'BIRTH-002', 28000, 12000, 11, 3, '2025-11-15T10:00:00'),
    (9, N'Assorted Cupcakes Box', 4, NULL, N'PAST-001', 8000, 3000, 31, 5, '2025-11-15T10:00:00'),
    (10, N'French Croissants', 4, NULL, N'PAST-002', 2000, 800, 70, 10, '2025-11-15T10:00:00'),
    (11, N'Fruit Jelly Medley', 5, NULL, N'JELLY-001', 5000, 2000, 22, 5, '2025-11-15T10:00:00'),
    (12, N'Custom Macarons', 6, NULL, N'CUST-001', 12000, 5000, 21, 2, '2025-11-15T10:00:00'),
    (13, N'Vintage Lace Cake', 1, N'Romantic vintage style cake', N'WED-005', 60000, 25000, 2, 10, '2025-11-15T10:00:00'),
    (14, N'Space Galaxy Cake', 2, N'Cool cake for little astronauts', N'KIDS-003', 40000, 17000, 5, 10, '2025-11-15T10:00:00'),
    (15, N'Rainbow Fruit Birthday', 3, N'Colorful and fresh fruit cake', N'BIRTH-003', 32000, 13000, 8, 10, '2025-11-15T10:00:00'),
    (16, N'Blueberry Muffins', 4, N'Soft and fluffy blueberry muffins', N'PAST-003', 1500, 500, 83, 10, '2025-11-15T10:00:00'),
    (17, N'Strawberry Jelly Cup', 5, N'Layered strawberry jelly', N'JELLY-002', 2500, 800, 30, 10, '2025-11-15T10:00:00'),
    (18, N'Artisan Chocolate Box', 6, N'Handmade premium chocolates', N'CUST-002', 15000, 6000, 19, 10, '2025-11-15T10:00:00'),
    (19, N'Pearl Cascade Cake', 1, N'Five tiers with sugar pearls', N'WED-006', 85000, 40000, 6, 2, '2025-11-15T10:00:00'),
    (20, N'Naked Berry Wedding Cake', 1, N'Semi-naked cake with fresh berries', N'WED-007', 50000, 22000, 4, 2, '2025-11-15T10:00:00'),
    (21, N'Mini Rose Wedding Cake', 1, N'Two small tiers for 10 guests', N'MWED-001', 30000, 13000, 6, 2, '2025-11-15T10:00:00'),
    (22, N'Mini Lavender Cake', 1, N'Lavender and honey mini cake', N'MWED-002', 28000, 12000, 1, 2, '2025-11-15T10:00:00'),
    (23, N'Mini Champagne Cake', 1, N'Champagne cream, one tier', N'MWED-003', 32000, 14000, 6, 2, '2025-11-15T10:00:00'),
    (24, N'Dinosaur Park Cake', 2, N'Dinosaurs and volcano topper', N'KIDS-004', 36000, 15000, 5, 2, '2025-11-15T10:00:00'),
    (25, N'Unicorn Dream Cake', 2, N'Rainbow layers and unicorn horn', N'KIDS-005', 37000, 15500, 0, 2, '2025-11-15T10:00:00');


INSERT INTO dbo.Products (ProductID, Name, CategoryID, Description, SKU, Price, Cost, StockQuantity, ReorderLevel, CreatedDate) VALUES
    (26, N'Race Car Cake', 2, N'Car track on chocolate base', N'KIDS-006', 34000, 14000, 7, 2, '2025-11-15T10:00:00'),
    (27, N'Pink or Blue Surprise Cake', 2, N'Colored filling inside', N'GEN-001', 30000, 12000, 6, 2, '2025-11-15T10:00:00'),
    (28, N'Balloon Pop Reveal Cake', 2, N'Balloon with confetti on top', N'GEN-002', 33000, 13500, 3, 2, '2025-11-15T10:00:00'),
    (29, N'Vanilla Number Cake', 3, N'Cake in the shape of a number', N'BIRTH-004', 27000, 11000, 7, 3, '2025-11-15T10:00:00'),
    (30, N'Honey Cake Medovik', 3, N'Classic layered honey cake', N'BIRTH-005', 22000, 9000, 14, 3, '2025-11-15T10:00:00'),
    (31, N'Napoleon Cake', 3, N'Puff pastry with custard', N'BIRTH-006', 21000, 8500, 3, 3, '2025-11-15T10:00:00'),
    (32, N'Tiramisu Birthday Cake', 3, N'Coffee and mascarpone', N'BIRTH-007', 26000, 11000, 10, 3, '2025-11-15T10:00:00'),
    (33, N'Cheesecake New York', 3, N'Baked cheesecake, 1.5 kg', N'BIRTH-008', 24000, 10000, 11, 3, '2025-11-15T10:00:00'),
    (34, N'Gata Armenian Pastry', 4, N'Traditional sweet bread', N'PAST-004', 3000, 1000, 55, 10, '2025-11-15T10:00:00'),
    (35, N'Eclair Box', 4, N'Six chocolate eclairs', N'PAST-005', 6000, 2400, 19, 5, '2025-11-15T10:00:00'),
    (36, N'Apple Strudel', 4, N'Warm apple and cinnamon', N'PAST-006', 4500, 1800, 16, 5, '2025-11-15T10:00:00'),
    (37, N'Cinnamon Rolls', 4, N'Four rolls with cream glaze', N'PAST-007', 3500, 1300, 32, 8, '2025-11-15T10:00:00'),
    (38, N'Baklava Tray', 4, N'Walnut baklava, 24 pieces', N'PAST-008', 9000, 3800, 18, 5, '2025-11-15T10:00:00'),
    (39, N'Red Velvet Cupcakes', 4, N'Box of six', N'CUP-001', 7000, 2700, 32, 6, '2025-11-15T10:00:00'),
    (40, N'Lemon Cupcakes', 4, N'Box of six with lemon curd', N'CUP-002', 6500, 2500, 5, 6, '2025-11-15T10:00:00'),
    (41, N'Chocolate Fudge Cupcakes', 4, N'Box of six', N'CUP-003', 7000, 2800, 24, 6, '2025-11-15T10:00:00'),
    (42, N'Salted Caramel Cupcakes', 4, N'Box of six', N'CUP-004', 7500, 3000, 24, 6, '2025-11-15T10:00:00'),
    (43, N'Mango Panna Cotta', 5, N'Italian cream with mango jelly', N'JELLY-003', 3000, 1100, 27, 8, '2025-11-15T10:00:00'),
    (44, N'Cherry Jelly Cake', 5, N'Sponge base with cherry jelly', N'JELLY-004', 14000, 5500, 15, 3, '2025-11-15T10:00:00'),
    (45, N'Broken Glass Jelly', 5, N'Colorful jelly cubes in cream', N'JELLY-005', 9000, 3500, 14, 4, '2025-11-15T10:00:00'),
    (46, N'Photo Print Cake', 6, N'Edible photo on top', N'CUST-003', 30000, 12000, 8, 2, '2025-11-15T10:00:00'),
    (47, N'Corporate Logo Cookies', 6, N'Box of 20 cookies with logo', N'CUST-004', 16000, 6500, 16, 3, '2025-11-15T10:00:00'),
    (48, N'Chocolate Strawberries', 6, N'12 strawberries in chocolate', N'CUST-005', 11000, 4500, 21, 3, '2025-11-15T10:00:00'),
    (49, N'Cake Pops Set', 6, N'Ten cake pops on sticks', N'CUST-006', 8500, 3400, 13, 3, '2025-11-15T10:00:00'),
    (50, N'Pistachio Macarons', 6, N'Box of 12', N'MAC-001', 9500, 3800, 25, 4, '2025-11-15T10:00:00');


INSERT INTO dbo.Products (ProductID, Name, CategoryID, Description, SKU, Price, Cost, StockQuantity, ReorderLevel, CreatedDate) VALUES
    (51, N'Raspberry Macarons', 6, N'Box of 12', N'MAC-002', 9500, 3800, 3, 4, '2025-11-15T10:00:00'),
    (52, N'Rainbow Macaron Tower', 6, N'60 macarons on a stand', N'MAC-003', 45000, 19000, 4, 1, '2025-11-15T10:00:00'),
    (53, N'Wedding Macaron Favors', 6, N'Boxed pairs for guests, 30 boxes', N'MAC-004', 38000, 16000, 7, 2, '2025-11-15T10:00:00'),
    (54, N'Seasonal Pumpkin Pie', 4, N'Autumn special', N'PAST-009', 8000, 3200, 0, 3, '2025-11-15T10:00:00'),
    (55, N'Old Recipe Fruitcake', 6, N'No longer produced', N'CUST-007', 12000, 5000, 5, 2, '2025-11-15T10:00:00');
SET IDENTITY_INSERT dbo.Products OFF;

-- ---------- Users ----------
SET IDENTITY_INSERT dbo.Users ON;
INSERT INTO dbo.Users (UserID, Email, PasswordHash, FirstName, LastName, PhoneNumber, DateOfBirth, CreatedDate) VALUES
    (1, N'testuser@example.com', N'hashed_string_123', N'John', N'Doe', N'+37499112233', NULL, '2025-11-19T11:55:00'),
    (2, N'test@example.com', N'hash123', N'Melanya', N'Test', NULL, NULL, '2025-11-20T19:41:00'),
    (3, N'test.user@example.com', N'$2b$10$MBhdaPLJ0CBJZbBXza3h.S0phRZpLJuKrqfD4NuIjsWGDbjIbKuh4', N'Test', N'Testyan', N'+37498000001', N'2000-06-06', '2025-11-21T11:03:00'),
    (4, N'melanya.a@example.com', N'$2b$10$sStrYgHTdS5uganFbCmxgGZmZ9w4QfPdf0xsaP9JEMRS0Gvu5e/Mg', N'Melanya', N'Avetisyan', N'+37498000002', N'2012-06-14', '2025-11-21T11:46:00'),
    (5, N'val.a@example.com', N'$2b$10$pMj1S4.fULkXRtS.n8AMslcFcII8GOO6Tf0ZXlxt23NdaGpAba.HF', N'Val', N'Avet', N'+37498000003', N'2005-09-14', '2025-11-22T15:40:00'),
    (6, N'ani.g@example.com', N'$2b$10$bGCoHch8ZO6d6yWKK1r0y5EKFxpLdWW3P0Vh5dH2KE/JcTy87ZxFT', N'Ani', N'Grigoryan', N'+37498000004', N'2000-06-07', '2025-11-22T18:13:00'),
    (7, N'aram.hakobyan0@example.com', N'$2b$10$8RWjZFFmFE7SFIVGGcxNdDIzmfYmcfwOk4mH/4KHZfOqGdtiS2k/k', N'Aram', N'Hakobyan', N'+37477830429', N'2004-08-10', '2025-12-01T14:16:00'),
    (8, N'narek.poghosyan1@example.com', N'$2b$10$RgiYpYf8eEJ0hD.oOfS20/MHRCtQ1ODlsDrYdLryRcSUyBUoydgSL', N'Narek', N'Poghosyan', N'+37499680097', N'1983-02-04', '2025-12-27T22:08:00'),
    (9, N'lusine.hakobyan2@example.com', N'$2b$10$lbaBWxohGhqxoBMfUfCL1qm1MvWeD1.Xs1GomNklynxjOWzuUkx.k', N'Lusine', N'Hakobyan', N'+37477466643', N'1982-04-27', '2025-12-10T21:30:00'),
    (10, N'gayane.khachatryan3@example.com', N'$2b$10$22Z6TIioJclaXQBDd6H4zWv9xdQ.L0aU5EdN4P5m203S63fdh8ch2', N'Gayane', N'Khachatryan', N'+37494587575', N'1993-10-21', '2026-01-23T14:50:00'),
    (11, N'tigran.hovhannisyan4@example.com', N'$2b$10$RbvRZGzyo5zFYzvAu7.rkvza8ag18BvpxT5OBwBI0P5VEfunZ4npu', N'Tigran', N'Hovhannisyan', N'+37491245095', N'1985-06-18', '2026-02-12T11:17:00'),
    (12, N'mariam.khachatryan5@example.com', N'$2b$10$EqaGDBdXARcO6MZ5etTMSlLBluwXHdLkNDq0tGp/z8L1s4R1Ug751', N'Mariam', N'Khachatryan', N'+37499665621', N'1977-08-01', '2026-03-18T12:53:00'),
    (13, N'hayk.avagyan6@example.com', N'$2b$10$5upB9nV8Zrfphh/WIcy8c683AJjaxdlt6q0or4glebNWmNVWZ7hiK', N'Hayk', N'Avagyan', N'+37477355709', N'1982-02-09', '2026-02-07T13:54:00'),
    (14, N'sona.harutyunyan7@example.com', N'$2b$10$OhDEjO8L/i672pVEe7MGx8HERRkIdNzau32k0lFKYZfIScUHS.y36', N'Sona', N'Harutyunyan', N'+37499660081', N'1980-05-01', '2026-02-14T11:23:00'),
    (15, N'gor.khachatryan8@example.com', N'$2b$10$bfX0MaRgQHFTli2N5kxg92ID1neBJbAgDU62hV18J6qyonLSoy9ix', N'Gor', N'Khachatryan', N'+37477174637', N'1997-05-23', '2025-12-09T11:18:00'),
    (16, N'ani.gevorgyan9@example.com', N'$2b$10$x.5yEWs92EYgOi28NBcSl/yJaM5NR9jgz76d4QvWPGhzpg.ik8R37', N'Ani', N'Gevorgyan', N'+37491910075', N'1985-05-11', '2025-12-10T15:05:00'),
    (17, N'levon.vardanyan10@example.com', N'$2b$10$cvbyDm6uvR9COoK2K4/QyRH6fpwIoum8CGcibJ1KK2TkBDnFjrt1Q', N'Levon', N'Vardanyan', N'+37494297816', N'1992-07-15', '2026-02-24T16:48:00'),
    (18, N'nare.harutyunyan11@example.com', N'$2b$10$uc9Qb5e4e/5iSH2qk0e4kXv7LcurjjAwh/E9ibraWePKDl2CsOJjn', N'Nare', N'Harutyunyan', N'+37493182804', N'1996-03-06', '2026-04-15T14:36:00'),
    (19, N'vahe.avagyan12@example.com', N'$2b$10$gTe7jpM5HQawsJw/fN4tfutLb6BnaG5kyMPDCk9MKcPv4tzRzK8yh', N'Vahe', N'Avagyan', N'+37498626169', N'1979-09-12', '2026-03-17T10:12:00'),
    (20, N'elen.petrosyan13@example.com', N'$2b$10$trFwhWN4JZAEodOYGYZboQ.hQOeUMBO/rcnAUfEOzMG63sL3aDk4B', N'Elen', N'Petrosyan', N'+37494204180', N'1989-04-28', '2026-03-05T11:28:00'),
    (21, N'armen.petrosyan14@example.com', N'$2b$10$2HInQGOhnuj41KMZ13byp4xzKm0metR6GJIJ1KtOFoNyr0EilrLZR', N'Armen', N'Petrosyan', N'+37477847006', N'1988-11-04', '2026-04-02T21:25:00'),
    (22, N'tatev.poghosyan15@example.com', N'$2b$10$Mha0BgBVglpq.VQxGQBJZuz4pStlnIERSEIg2082zgZMq1Mi8lDaw', N'Tatev', N'Poghosyan', N'+37498485415', N'1978-06-28', '2026-04-03T11:54:00'),
    (23, N'samvel.mkrtchyan16@example.com', N'$2b$10$ejnN.91UOubrHwD1A4Hm0xzjMxAnT4sJ1Ld1xIwlpaoTHMWqqQcLQ', N'Samvel', N'Mkrtchyan', N'+37493901280', N'1984-04-25', '2025-12-15T08:13:00'),
    (24, N'lilit.khachatryan17@example.com', N'$2b$10$953nmR2G62khFrHl53CFtiHJv5D3Wn6RF3LpIUDd22SstivypEoGo', N'Lilit', N'Khachatryan', N'+37493910389', N'1979-11-03', '2026-01-20T10:38:00'),
    (25, N'davit.hovhannisyan18@example.com', N'$2b$10$RoIQqlwOIluoOJ0sAslVZp8WaPRHjKCpOuRSVT2Dysc2i3bcl6Wt2', N'Davit', N'Hovhannisyan', N'+37499731977', N'1984-05-24', '2026-04-22T18:24:00');

INSERT INTO dbo.Users (UserID, Email, PasswordHash, FirstName, LastName, PhoneNumber, DateOfBirth, CreatedDate) VALUES
    (26, N'mane.karapetyan19@example.com', N'$2b$10$XPeE7tLNiISg3Q1Ja3qBzEwtcvItaBmKoQPCi6P63.IAeZR0MickN', N'Mane', N'Karapetyan', N'+37493956572', N'1991-09-14', '2026-02-11T20:24:00');
SET IDENTITY_INSERT dbo.Users OFF;

-- A few users logged in recently; one account is disabled
UPDATE dbo.Users SET LastLoginDate = DATEADD(hour, -UserID * 7, '2026-11-18T20:00:00') WHERE UserID % 3 <> 0;
UPDATE dbo.Users SET IsActive = 0 WHERE UserID = 26;

-- ---------- Addresses ----------
SET IDENTITY_INSERT dbo.Addresses ON;
INSERT INTO dbo.Addresses (AddressID, UserID, Street, City, Country, PostalCode) VALUES
    (1, 1, N'Arami St 82', N'Yerevan', N'Armenia', N'0080'),
    (2, 2, N'Tumanyan St 108', N'Yerevan', N'Armenia', N'0064'),
    (3, 3, N'Abovyan St 81', N'Yerevan', N'Armenia', N'0066'),
    (4, 4, N'Mashtots Ave 38', N'Yerevan', N'Armenia', N'0055'),
    (5, 5, N'Sayat-Nova Ave 31', N'Yerevan', N'Armenia', N'0074'),
    (6, 6, N'Tumanyan St 68', N'Yerevan', N'Armenia', N'0047'),
    (7, 7, N'Teryan St 65', N'Moscow', N'Russia', N'119065'),
    (8, 8, N'Pushkin St 6', N'Yerevan', N'Armenia', N'0082'),
    (9, 9, N'Baghramyan Ave 96', N'Moscow', N'Russia', N'119003'),
    (10, 9, N'Tumanyan St 45', N'Yerevan', N'Armenia', N'0031'),
    (11, 9, N'Tumanyan St 99', N'Vanadzor', N'Armenia', N'2075'),
    (12, 10, N'Sayat-Nova Ave 70', N'Yerevan', N'Armenia', N'0044'),
    (13, 10, N'Mashtots Ave 107', N'Vanadzor', N'Armenia', N'2088'),
    (14, 11, N'Pushkin St 81', N'Moscow', N'Russia', N'119024'),
    (15, 11, N'Tumanyan St 92', N'Vanadzor', N'Armenia', N'2059'),
    (16, 11, N'Komitas Ave 6', N'Yerevan', N'Armenia', N'0026'),
    (17, 12, N'Baghramyan Ave 66', N'Yerevan', N'Armenia', N'0051'),
    (18, 13, N'Komitas Ave 37', N'Yerevan', N'Armenia', N'0046'),
    (19, 13, N'Abovyan St 111', N'Dilijan', N'Armenia', N'3984'),
    (20, 13, N'Tumanyan St 103', N'Yerevan', N'Armenia', N'0048'),
    (21, 14, N'Pushkin St 115', N'Tbilisi', N'Georgia', N'0150'),
    (22, 14, N'Mashtots Ave 64', N'Yerevan', N'Armenia', N'0089'),
    (23, 14, N'Teryan St 35', N'Yerevan', N'Armenia', N'0011'),
    (24, 15, N'Isahakyan St 106', N'Yerevan', N'Armenia', N'0024'),
    (25, 15, N'Sayat-Nova Ave 14', N'Yerevan', N'Armenia', N'0011');
INSERT INTO dbo.Addresses (AddressID, UserID, Street, City, Country, PostalCode) VALUES
    (26, 15, N'Baghramyan Ave 40', N'Yerevan', N'Armenia', N'0058'),
    (27, 16, N'Pushkin St 45', N'Yerevan', N'Armenia', N'0058'),
    (28, 16, N'Sayat-Nova Ave 79', N'Yerevan', N'Armenia', N'0056'),
    (29, 16, N'Abovyan St 10', N'Yerevan', N'Armenia', N'0086'),
    (30, 17, N'Mashtots Ave 4', N'Yerevan', N'Armenia', N'0019'),
    (31, 17, N'Pushkin St 5', N'Dilijan', N'Armenia', N'3917'),
    (32, 17, N'Sayat-Nova Ave 47', N'Yerevan', N'Armenia', N'0050'),
    (33, 18, N'Pushkin St 48', N'Gyumri', N'Armenia', N'3148'),
    (34, 19, N'Isahakyan St 18', N'Vanadzor', N'Armenia', N'2068'),
    (35, 19, N'Sayat-Nova Ave 84', N'Yerevan', N'Armenia', N'0036'),
    (36, 19, N'Tumanyan St 4', N'Yerevan', N'Armenia', N'0095'),
    (37, 20, N'Arami St 117', N'Yerevan', N'Armenia', N'0072'),
    (38, 20, N'Baghramyan Ave 91', N'Yerevan', N'Armenia', N'0058'),
    (39, 21, N'Baghramyan Ave 89', N'Moscow', N'Russia', N'119063'),
    (40, 21, N'Mashtots Ave 110', N'Yerevan', N'Armenia', N'0010'),
    (41, 22, N'Pushkin St 12', N'Yerevan', N'Armenia', N'0088'),
    (42, 22, N'Sayat-Nova Ave 86', N'Moscow', N'Russia', N'119045'),
    (43, 22, N'Teryan St 70', N'Gyumri', N'Armenia', N'3138'),
    (44, 23, N'Mashtots Ave 102', N'Dilijan', N'Armenia', N'3947'),
    (45, 23, N'Tumanyan St 26', N'Yerevan', N'Armenia', N'0018'),
    (46, 24, N'Abovyan St 47', N'Vanadzor', N'Armenia', N'2071'),
    (47, 24, N'Pushkin St 103', N'Yerevan', N'Armenia', N'0071'),
    (48, 25, N'Tumanyan St 9', N'Gyumri', N'Armenia', N'3140'),
    (49, 25, N'Pushkin St 68', N'Yerevan', N'Armenia', N'0053'),
    (50, 26, N'Tumanyan St 17', N'Dilijan', N'Armenia', N'3941');
INSERT INTO dbo.Addresses (AddressID, UserID, Street, City, Country, PostalCode) VALUES
    (51, 26, N'Pushkin St 60', N'Gyumri', N'Armenia', N'3188'),
    (52, 26, N'Mashtots Ave 113', N'Yerevan', N'Armenia', N'0071'),
    (53, 1, N'Tumanyan St 5', N'Yerevan', N'Armenia', N'0001');
SET IDENTITY_INSERT dbo.Addresses OFF;

-- ---------- Orders (46) and order items (107) ----------
-- Orders are inserted with TotalAmount = 0; trg_OrderItems_UpdateTotal calculates it
SET IDENTITY_INSERT dbo.Orders ON;
INSERT INTO dbo.Orders (OrderID, UserID, OrderDate, Status, ShippingAddressID, CouponCode, DiscountPercent, LastModifiedDate) VALUES
    (1, 1, '2025-12-03T19:41:00', N'Delivered', 1, NULL, 0, '2025-12-03T19:41:00'),
    (2, 3, '2025-12-04T15:08:00', N'Delivered', 3, NULL, 0, '2025-12-04T15:08:00'),
    (3, 9, '2025-12-23T14:51:00', N'Delivered', 11, NULL, 0, '2025-12-23T14:51:00'),
    (4, 7, '2026-01-02T11:28:00', N'Delivered', 7, NULL, 0, '2026-01-02T11:28:00'),
    (5, 14, '2026-02-22T17:24:00', N'Delivered', 22, N'WELCOME10', 10, '2026-02-22T17:24:00'),
    (6, 24, '2026-02-25T11:00:00', N'Pending', 46, NULL, 0, '2026-02-25T11:00:00'),
    (7, 2, '2026-03-24T21:07:00', N'Delivered', 2, NULL, 0, '2026-03-24T21:07:00'),
    (8, 13, '2026-04-04T09:18:00', N'Delivered', 20, NULL, 0, '2026-04-04T09:18:00'),
    (9, 10, '2026-04-10T12:19:00', N'Delivered', 12, NULL, 0, '2026-04-10T12:19:00'),
    (10, 7, '2026-04-14T13:05:00', N'Delivered', 7, NULL, 0, '2026-04-14T13:05:00'),
    (11, 10, '2026-05-13T18:47:00', N'Delivered', 13, NULL, 0, '2026-05-13T18:47:00'),
    (12, 3, '2026-05-17T13:54:00', N'Delivered', 3, NULL, 0, '2026-05-17T13:54:00'),
    (13, 19, '2026-05-22T10:26:00', N'Delivered', 36, NULL, 0, '2026-05-22T10:26:00'),
    (14, 12, '2026-05-26T14:35:00', N'Delivered', 17, NULL, 0, '2026-05-26T14:35:00'),
    (15, 7, '2026-05-27T09:47:00', N'Delivered', 7, NULL, 0, '2026-05-27T09:47:00'),
    (16, 12, '2026-06-08T12:37:00', N'Delivered', 17, N'WEDDING15', 15, '2026-06-08T12:37:00'),
    (17, 22, '2026-06-13T15:05:00', N'Pending', 43, NULL, 0, '2026-06-13T15:05:00'),
    (18, 12, '2026-06-15T20:38:00', N'Delivered', 17, N'SUMMER25', 25, '2026-06-15T20:38:00'),
    (19, 10, '2026-06-17T16:31:00', N'Delivered', 12, N'WEDDING15', 15, '2026-06-17T16:31:00'),
    (20, 2, '2026-06-17T16:51:00', N'Delivered', 2, NULL, 0, '2026-06-17T16:51:00'),
    (21, 20, '2026-06-17T19:46:00', N'Delivered', 38, NULL, 0, '2026-06-17T19:46:00'),
    (22, 10, '2026-06-17T20:49:00', N'Delivered', 12, NULL, 0, '2026-06-17T20:49:00'),
    (23, 16, '2026-07-02T10:59:00', N'Delivered', 28, N'CAKE20', 20, '2026-07-02T10:59:00'),
    (24, 15, '2026-07-03T15:32:00', N'Delivered', 24, NULL, 0, '2026-07-03T15:32:00'),
    (25, 21, '2026-07-19T09:16:00', N'Delivered', 39, NULL, 0, '2026-07-19T09:16:00');
INSERT INTO dbo.Orders (OrderID, UserID, OrderDate, Status, ShippingAddressID, CouponCode, DiscountPercent, LastModifiedDate) VALUES
    (26, 24, '2026-07-20T16:55:00', N'Delivered', 47, NULL, 0, '2026-07-20T16:55:00'),
    (27, 6, '2026-07-22T11:56:00', N'Delivered', 6, NULL, 0, '2026-07-22T11:56:00'),
    (28, 4, '2026-07-22T12:32:00', N'Shipped', 4, NULL, 0, '2026-07-22T12:32:00'),
    (29, 4, '2026-07-22T12:33:00', N'Delivered', 4, N'CAKE20', 20, '2026-07-22T12:33:00'),
    (30, 1, '2026-07-23T10:12:00', N'Delivered', 1, N'CAKE20', 20, '2026-07-23T10:12:00'),
    (31, 14, '2026-08-06T21:08:00', N'Delivered', 23, NULL, 0, '2026-08-06T21:08:00'),
    (32, 10, '2026-08-16T19:34:00', N'Delivered', 13, N'WELCOME10', 10, '2026-08-16T19:34:00'),
    (33, 2, '2026-08-19T12:15:00', N'Delivered', 2, N'WELCOME10', 10, '2026-08-19T12:15:00'),
    (34, 14, '2026-08-21T15:52:00', N'Delivered', 21, NULL, 0, '2026-08-21T15:52:00'),
    (35, 7, '2026-08-24T16:13:00', N'Delivered', 7, NULL, 0, '2026-08-24T16:13:00'),
    (36, 21, '2026-09-10T14:18:00', N'Delivered', 40, NULL, 0, '2026-09-10T14:18:00'),
    (37, 24, '2026-09-10T16:43:00', N'Delivered', 47, NULL, 0, '2026-09-10T16:43:00'),
    (38, 6, '2026-09-21T13:45:00', N'Delivered', 6, NULL, 0, '2026-09-21T13:45:00'),
    (39, 17, '2026-10-03T17:28:00', N'Delivered', 31, NULL, 0, '2026-10-03T17:28:00'),
    (40, 18, '2026-10-17T12:36:00', N'Delivered', 33, NULL, 0, '2026-10-17T12:36:00'),
    (41, 16, '2026-11-01T15:50:00', N'Delivered', 28, N'WELCOME10', 10, '2026-11-01T15:50:00'),
    (42, 20, '2026-11-03T11:42:00', N'Shipped', 38, NULL, 0, '2026-11-03T11:42:00'),
    (43, 17, '2026-11-03T21:23:00', N'Shipped', 30, N'WELCOME10', 10, '2026-11-03T21:23:00'),
    (44, 8, '2026-11-08T14:59:00', N'Processing', 8, NULL, 0, '2026-11-08T14:59:00'),
    (45, 18, '2026-11-08T17:21:00', N'Processing', 33, NULL, 0, '2026-11-08T17:21:00'),
    (46, 5, '2026-11-09T17:31:00', N'Pending', 5, NULL, 0, '2026-11-09T17:31:00');
SET IDENTITY_INSERT dbo.Orders OFF;
INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
    (1, 1, 1, 45000),
    (2, 24, 1, 36000),
    (2, 10, 1, 2000),
    (2, 39, 2, 7000),
    (3, 33, 1, 24000),
    (3, 16, 3, 1500),
    (4, 39, 3, 7000),
    (4, 16, 3, 1500),
    (5, 52, 1, 45000),
    (5, 16, 3, 1500),
    (5, 36, 1, 4500),
    (5, 10, 3, 2000),
    (6, 42, 4, 7500),
    (7, 50, 2, 9500),
    (7, 9, 2, 8000),
    (8, 11, 3, 5000),
    (8, 37, 2, 3500),
    (9, 32, 1, 26000),
    (9, 37, 3, 3500),
    (9, 42, 3, 7500),
    (10, 55, 1, 12000),
    (10, 10, 6, 2000),
    (11, 33, 1, 24000),
    (11, 44, 3, 14000),
    (11, 42, 4, 7500),
    (12, 36, 3, 4500),
    (12, 35, 1, 6000),
    (12, 16, 2, 1500),
    (13, 45, 4, 9000),
    (13, 48, 3, 11000),
    (13, 9, 2, 8000),
    (13, 47, 1, 16000),
    (14, 33, 1, 24000),
    (14, 39, 1, 7000),
    (15, 23, 1, 32000),
    (16, 39, 4, 7000),
    (16, 48, 3, 11000),
    (17, 9, 2, 8000),
    (17, 48, 4, 11000),
    (17, 38, 2, 9000);
INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
    (17, 12, 2, 12000),
    (18, 31, 1, 21000),
    (18, 44, 2, 14000),
    (18, 49, 2, 8500),
    (19, 26, 1, 34000),
    (20, 30, 1, 22000),
    (20, 45, 4, 9000),
    (20, 10, 3, 2000),
    (21, 53, 1, 38000),
    (21, 49, 2, 8500),
    (22, 19, 1, 85000),
    (22, 38, 2, 9000),
    (22, 47, 2, 16000),
    (23, 50, 4, 9500),
    (23, 16, 3, 1500),
    (24, 40, 1, 6500),
    (24, 49, 2, 8500),
    (25, 43, 4, 3000),
    (25, 12, 3, 12000),
    (26, 34, 3, 3000),
    (26, 18, 4, 15000),
    (26, 44, 4, 14000),
    (27, 1, 1, 45000),
    (28, 1, 1, 45000),
    (29, 3, 1, 75000),
    (30, 27, 1, 30000),
    (30, 50, 2, 9500),
    (31, 8, 1, 28000),
    (31, 43, 2, 3000),
    (31, 16, 2, 1500),
    (31, 36, 3, 4500),
    (32, 16, 4, 1500),
    (32, 49, 3, 8500),
    (33, 41, 1, 7000),
    (33, 34, 4, 3000),
    (33, 10, 3, 2000),
    (34, 43, 1, 3000),
    (35, 36, 3, 4500),
    (35, 50, 2, 9500),
    (36, 42, 1, 7500);
INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
    (36, 45, 2, 9000),
    (36, 34, 4, 3000),
    (37, 53, 1, 38000),
    (37, 34, 3, 3000),
    (37, 41, 2, 7000),
    (38, 19, 1, 85000),
    (38, 45, 2, 9000),
    (39, 37, 1, 3500),
    (40, 34, 1, 3000),
    (40, 41, 2, 7000),
    (41, 19, 1, 85000),
    (41, 10, 1, 2000),
    (41, 9, 3, 8000),
    (41, 36, 3, 4500),
    (42, 37, 1, 3500),
    (42, 10, 3, 2000),
    (42, 9, 2, 8000),
    (42, 11, 4, 5000),
    (43, 30, 1, 22000),
    (43, 12, 3, 12000),
    (44, 16, 3, 1500),
    (44, 41, 3, 7000),
    (45, 47, 3, 16000),
    (45, 49, 4, 8500),
    (45, 48, 2, 11000),
    (46, 52, 1, 45000),
    (46, 12, 3, 12000);

-- ---------- Payments ----------
-- Shipped / delivered orders are paid; processing orders are waiting for card confirmation
INSERT INTO dbo.Payments (OrderID, Amount, PaymentMethod, PaymentDate, Status)
SELECT OrderID,
       TotalAmount,
       CASE OrderID % 3 WHEN 0 THEN 'Cash' WHEN 1 THEN 'Card' ELSE 'BankTransfer' END,
       DATEADD(minute, 15, OrderDate),
       'Completed'
FROM dbo.Orders
WHERE Status IN ('Shipped', 'Delivered');

INSERT INTO dbo.Payments (OrderID, Amount, PaymentMethod, PaymentDate, Status)
SELECT OrderID, TotalAmount, 'Card', DATEADD(minute, 5, OrderDate), 'Pending'
FROM dbo.Orders
WHERE Status = 'Processing';

-- ---------- Cancelled orders ----------
-- Cancelled through the procedure: stock is restored, history and notification are written
-- Order 6 was paid before it was cancelled -> the payment becomes Refunded
INSERT INTO dbo.Payments (OrderID, Amount, PaymentMethod, PaymentDate, Status)
SELECT OrderID, TotalAmount, 'Card', DATEADD(minute, 10, OrderDate), 'Completed'
FROM dbo.Orders WHERE OrderID = 6;

EXEC dbo.sp_CancelOrder @OrderID = 6;
EXEC dbo.sp_CancelOrder @OrderID = 17;

-- Discontinued products: DELETE is turned into IsActive = 0 by trg_Products_DeleteProtection
DELETE FROM dbo.Products WHERE SKU IN ('PAST-009', 'CUST-007');

-- ---------- Reviews (42), only for delivered products ----------
INSERT INTO dbo.Reviews (ProductID, UserID, Rating, Comment, ReviewDate) VALUES
    (24, 3, 3, N'Taste was fine, decoration could be better', '2025-12-06T19:08:00'),
    (10, 3, 4, N'Very tasty, a bit too sweet', '2025-12-08T18:08:00'),
    (52, 14, 3, N'Taste was fine, decoration could be better', '2026-02-24T19:24:00'),
    (16, 14, 4, N'Nice cake, will order again', '2026-02-25T18:24:00'),
    (36, 14, 4, N'Good, delivery was late by 20 min', '2026-03-03T18:24:00'),
    (50, 2, 5, N'Perfect, everyone loved it!', '2026-03-30T02:07:00'),
    (9, 2, 3, N'OK, nothing special', '2026-03-30T02:07:00'),
    (42, 10, 4, N'Good, delivery was late by 20 min', '2026-04-16T14:19:00'),
    (55, 7, 4, N'Good, delivery was late by 20 min', '2026-04-17T18:05:00'),
    (10, 7, 5, N'Best cake in town', '2026-04-19T15:05:00'),
    (44, 10, 5, N'Best cake in town', '2026-05-17T18:47:00'),
    (36, 3, 4, N'Very tasty, a bit too sweet', '2026-05-25T15:54:00'),
    (45, 19, 5, N'Best cake in town', '2026-06-01T15:26:00'),
    (9, 19, 1, N'Arrived damaged', '2026-05-31T13:26:00'),
    (47, 19, 5, N'Exactly like the photo', '2026-05-26T15:26:00'),
    (39, 12, 1, N'Arrived damaged', '2026-05-28T18:35:00'),
    (23, 7, 5, N'Exactly like the photo', '2026-05-29T09:47:00'),
    (31, 12, 5, N'Beautiful and delicious', '2026-06-19T20:38:00'),
    (44, 12, 5, N'Exactly like the photo', '2026-06-25T01:38:00'),
    (26, 10, 5, N'Best cake in town', '2026-06-19T20:31:00'),
    (30, 2, 5, N'Exactly like the photo', '2026-06-27T21:51:00'),
    (45, 2, 2, N'Cream was too heavy', '2026-06-20T16:51:00'),
    (53, 20, 5, N'Exactly like the photo', '2026-06-24T21:46:00'),
    (19, 10, 4, N'Very tasty, a bit too sweet', '2026-06-23T01:49:00'),
    (47, 10, 5, N'Exactly like the photo', '2026-06-19T20:49:00');
INSERT INTO dbo.Reviews (ProductID, UserID, Rating, Comment, ReviewDate) VALUES
    (16, 16, 5, N'Beautiful and delicious', '2026-07-04T15:59:00'),
    (49, 15, 4, N'Very tasty, a bit too sweet', '2026-07-10T19:32:00'),
    (43, 21, 2, N'Smaller than expected', '2026-07-24T10:16:00'),
    (34, 24, 4, N'Nice cake, will order again', '2026-07-26T20:55:00'),
    (18, 24, 5, N'Beautiful and delicious', '2026-07-27T16:55:00'),
    (44, 24, 3, N'Taste was fine, decoration could be better', '2026-07-28T16:55:00'),
    (27, 1, 5, N'Exactly like the photo', '2026-08-02T12:12:00'),
    (50, 1, 5, N'Best cake in town', '2026-07-26T14:12:00'),
    (16, 10, 5, N'Perfect, everyone loved it!', '2026-08-24T21:34:00'),
    (49, 10, 3, N'OK, nothing special', '2026-08-25T22:34:00'),
    (34, 2, 5, N'Best cake in town', '2026-08-27T12:15:00'),
    (10, 2, 4, N'Very tasty, a bit too sweet', '2026-08-22T14:15:00'),
    (36, 7, 5, N'Best cake in town', '2026-09-01T18:13:00'),
    (37, 17, 5, N'Best cake in town', '2026-10-05T17:28:00'),
    (34, 18, 4, N'Very tasty, a bit too sweet', '2026-10-24T15:36:00'),
    (9, 16, 2, N'Cream was too heavy', '2026-11-06T19:50:00'),
    (36, 16, 5, N'Best cake in town', '2026-11-07T17:50:00');

-- ---------- Shopping carts (15) and wishlist (22) ----------
INSERT INTO dbo.ShoppingCart (UserID, ProductID, Quantity, AddedDate) VALUES
    (16, 38, 2, '2026-11-13T20:00:00'),
    (5, 42, 1, '2026-11-17T10:00:00'),
    (5, 47, 1, '2026-11-14T09:00:00'),
    (3, 37, 2, '2026-11-15T16:00:00'),
    (6, 40, 1, '2026-11-14T14:00:00'),
    (14, 50, 2, '2026-11-15T11:00:00'),
    (14, 18, 2, '2026-11-15T13:00:00'),
    (9, 50, 2, '2026-11-13T14:00:00'),
    (9, 48, 2, '2026-11-14T22:00:00'),
    (22, 38, 1, '2026-11-13T18:00:00'),
    (10, 17, 1, '2026-11-17T20:00:00'),
    (10, 49, 1, '2026-11-17T21:00:00'),
    (26, 50, 1, '2026-11-16T19:00:00'),
    (6, 1, 1, '2026-11-17T12:04:00'),
    (4, 5, 1, '2026-11-17T12:35:00');
INSERT INTO dbo.Wishlist (UserID, ProductID, AddedDate) VALUES
    (16, 9, '2026-11-05T12:00:00'),
    (9, 43, '2026-07-12T15:00:00'),
    (26, 25, '2026-06-08T18:00:00'),
    (16, 38, '2026-09-09T17:00:00'),
    (23, 27, '2026-10-01T21:00:00'),
    (12, 45, '2026-10-10T19:00:00'),
    (3, 7, '2026-07-11T19:00:00'),
    (12, 11, '2026-11-10T09:00:00'),
    (19, 42, '2026-11-11T15:00:00'),
    (25, 22, '2026-09-02T09:00:00'),
    (4, 17, '2026-07-09T20:00:00'),
    (17, 36, '2026-10-12T18:00:00'),
    (8, 29, '2026-08-07T16:00:00'),
    (25, 44, '2026-10-12T17:00:00'),
    (5, 23, '2026-06-08T10:00:00'),
    (10, 27, '2026-06-02T22:00:00'),
    (24, 10, '2026-08-05T14:00:00'),
    (15, 51, '2026-07-09T16:00:00'),
    (12, 31, '2026-06-08T20:00:00'),
    (23, 29, '2026-08-02T13:00:00'),
    (2, 52, '2026-11-02T09:00:00'),
    (11, 42, '2026-06-11T21:00:00');

-- ---------- Row counts ----------
SELECT 'Users' AS TableName, COUNT(*) AS Rows FROM dbo.Users
UNION ALL SELECT 'Addresses', COUNT(*) FROM dbo.Addresses
UNION ALL SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL SELECT 'Products', COUNT(*) FROM dbo.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderItems', COUNT(*) FROM dbo.OrderItems
UNION ALL SELECT 'Payments', COUNT(*) FROM dbo.Payments
UNION ALL SELECT 'Reviews', COUNT(*) FROM dbo.Reviews
UNION ALL SELECT 'ShoppingCart', COUNT(*) FROM dbo.ShoppingCart
UNION ALL SELECT 'Wishlist', COUNT(*) FROM dbo.Wishlist
UNION ALL SELECT 'LowStockAlerts', COUNT(*) FROM dbo.LowStockAlerts
UNION ALL SELECT 'ProductAudit', COUNT(*) FROM dbo.ProductAudit;
GO
