import yfinance as yf
import json

# Get currency exchange rate
usd_inr = yf.Ticker("USDINR=X")

data = usd_inr.history(period="1d")

new_data = json.loads(data.to_json())

print(json.dumps(new_data,indent=2))
print(len(new_data['Close']))

for item in new_data['Close']:
    name = item
    price = new_data['Close'][item]
    print(name,price)