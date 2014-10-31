Feature: Product list
Should display the product list that is similar to the google spreadsheet that I have
Should have a search bar that would filter the page based on what is being type

Scenario: Single Product Existence on Page
  Given product does exists with name: "Milk", special: "2.99", normal: "4.99", diff: "2.00", sku: "1"
  When I go to the home page
  Then I should see "Milk"
  And I should see "NZ$2.99"
  And I should see "NZ$4.99"
  And I should see "NZ$2.00"

Scenario: Multiple Products Existence
  Given the following products
    | name | volume | sku | special | normal | diff | aisle | discount |
    | Seafood Bar Fish Fillets Basa | frozen 1kg pack | 771812 | 8.40 | 14.99 | 6.59 | Meat & Seafood, Fresh Fish | 43.96 |
    | Seafood Bar Fish Fillets Snapper Skinned & Boned | per kg | 321532 | 36.00 | 38.99 | 2.99 | Meat & Seafood, Fresh Fish |  7.67 |
    | Seafood Bar Fish Fillets Tarakihi Skinned & Boned | per kg | 293285 | 25.00 | 29.99 | 4.99 | Meat & Seafood, Fresh Fish |  16.64 |
  When I go to the home page
  Then I should see the following products: 
    | name | volume | sku | special | normal | diff | aisle | discount |
    | Seafood Bar Fish Fillets Basa | frozen 1kg pack | 771812 | NZ$8.40 | NZ$14.99 | NZ$6.59 | Meat & Seafood, Fresh Fish | 43.96% |
    | Seafood Bar Fish Fillets Snapper Skinned & Boned | per kg | 321532 | NZ$36.00 | NZ$38.99 | NZ$2.99 | Meat & Seafood, Fresh Fish |  7.67% |
    | Seafood Bar Fish Fillets Tarakihi Skinned & Boned | per kg | 293285 | NZ$25.00 | NZ$29.99 | NZ$4.99 | Meat & Seafood, Fresh Fish |  16.64% |
  And products should have 3 item

Scenario: Diff and Discount Calculation Automation
  Given product exists with name: "Milk", special: "2.99", normal: "4.99"
  When I go to the home page
  Then product's diff must be "NZ$2.00"
  And product's discount must be "40.08%"
  And I should see "NZ$2.99"
  And I should see "NZ$4.99"
  And I should see "NZ$2.00"
  And I should see "40.08%"
