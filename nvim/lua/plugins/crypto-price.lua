-- Simple crypto price fetcher for Neovim
-- Save this as ~/.config/nvim/lua/crypto-price.lua
-- Then add require('crypto-price') to your init.lua

local M = {}

-- Hardcoded mapping of popular cryptocurrencies
local crypto_map = {
  btc = "bitcoin",
  eth = "ethereum",
  bnb = "binancecoin",
  sol = "solana",
  xrp = "ripple",
  ada = "cardano",
  avax = "avalanche-2",
  doge = "dogecoin",
  dot = "polkadot",
  matic = "matic-network",
  link = "chainlink",
  uni = "uniswap",
  atom = "cosmos",
  ltc = "litecoin",
  near = "near",
  ftm = "fantom",
  xlm = "stellar",
  algo = "algorand",
  vet = "vechain",
  icp = "internet-computer",
  fil = "filecoin",
  apt = "aptos",
  arb = "arbitrum",
  op = "optimism",
  inj = "injective-protocol",
  sui = "sui",
  tia = "celestia",
}

-- Display names for better output
local display_names = {
  bitcoin = "Bitcoin (BTC)",
  ethereum = "Ethereum (ETH)",
  binancecoin = "BNB",
  solana = "Solana (SOL)",
  ripple = "XRP",
  cardano = "Cardano (ADA)",
  ["avalanche-2"] = "Avalanche (AVAX)",
  dogecoin = "Dogecoin (DOGE)",
  polkadot = "Polkadot (DOT)",
  ["matic-network"] = "Polygon (MATIC)",
  chainlink = "Chainlink (LINK)",
  uniswap = "Uniswap (UNI)",
  cosmos = "Cosmos (ATOM)",
  litecoin = "Litecoin (LTC)",
  near = "NEAR Protocol",
  fantom = "Fantom (FTM)",
  stellar = "Stellar (XLM)",
  algorand = "Algorand (ALGO)",
  vechain = "VeChain (VET)",
  ["internet-computer"] = "Internet Computer (ICP)",
  filecoin = "Filecoin (FIL)",
  aptos = "Aptos (APT)",
  arbitrum = "Arbitrum (ARB)",
  optimism = "Optimism (OP)",
  ["injective-protocol"] = "Injective (INJ)",
  sui = "Sui (SUI)",
  ["sei-network"] = "Sei (SEI)",
  celestia = "Celestia (TIA)",
}

-- Function to fetch crypto price
local function fetch_crypto_price(args)
  -- Check if curl is available
  local curl = vim.fn.executable('curl')
  if curl == 0 then
    vim.notify("curl is required but not found in PATH", vim.log.levels.ERROR)
    return
  end

  -- Get the crypto symbol from arguments
  local input = args.args:lower():gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
  if input == "" then
    vim.notify("Usage: :Price <symbol>  (e.g., :Price btc)", vim.log.levels.WARN)
    return
  end

  -- Look up the coin ID
  local coin_id = crypto_map[input]
  if not coin_id then
    vim.notify(string.format("Unknown cryptocurrency '%s'. Try: btc, eth, sol, ada, etc.", input), vim.log.levels.ERROR)
    return
  end

  -- Get display name
  local display_name = display_names[coin_id] or coin_id

  -- Show loading message
  -- vim.notify("Fetching price for " .. display_name .. "...", vim.log.levels.INFO)

  -- CoinGecko API endpoint
  local url = string.format(
    "https://api.coingecko.com/api/v3/simple/price?ids=%s&vs_currencies=usd&include_24hr_change=true&include_market_cap=true",
    coin_id
  )
  
  -- Execute curl command with timeout
  local cmd = string.format('curl -s --connect-timeout 5 --max-time 10 "%s"', url)
  local handle = io.popen(cmd)
  if not handle then
    vim.notify("Failed to execute curl command", vim.log.levels.ERROR)
    return
  end
  
  local result = handle:read("*a")
  handle:close()
  
  -- Check for empty response
  if result == "" then
    vim.notify("Failed to fetch price. Check your internet connection.", vim.log.levels.ERROR)
    return
  end
  
  -- Parse JSON response
  local price = result:match('"usd":([%d%.]+)')
  local change = result:match('"usd_24h_change":([%-]?[%d%.]+)')
  local market_cap = result:match('"usd_market_cap":([%d%.]+)')
  
  if price then
    -- Format price
    local price_num = tonumber(price)
    local formatted_price
    if price_num < 0.01 then
      formatted_price = string.format("$%.6f", price_num)
    elseif price_num < 1 then
      formatted_price = string.format("$%.4f", price_num)
    else
      formatted_price = string.format("$%s", price:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
    end
    
    -- Format change percentage
    local change_str = ""
    if change then
      local change_num = tonumber(change)
      local change_icon = change_num >= 0 and "↑" or "↓"
      local change_color = change_num >= 0 and "🟢" or "🔴"
      change_str = string.format(" %s %.2f%% %s", change_color, math.abs(change_num), change_icon)
    end
    
    -- Format market cap
    local mcap_str = ""
    if market_cap then
      local mcap_num = tonumber(market_cap)
      if mcap_num >= 1e9 then
        mcap_str = string.format(" (MC: $%.2fB)", mcap_num / 1e9)
      elseif mcap_num >= 1e6 then
        mcap_str = string.format(" (MC: $%.2fM)", mcap_num / 1e6)
      end
    end
    
    -- Display result
    vim.notify(string.format("%s: %s%s%s", display_name, formatted_price, change_str, mcap_str), vim.log.levels.INFO)
  else
    vim.notify("Failed to parse price data. API might be down or rate limited.", vim.log.levels.ERROR)
  end
end

-- Function to provide completion
local function crypto_complete(arg_lead, cmd_line, cursor_pos)
  local completions = {}
  local seen = {}
  
  for symbol, _ in pairs(crypto_map) do
    -- Avoid duplicates (e.g., both "btc" and "bitcoin" map to same coin)
    if not seen[symbol] and symbol:find("^" .. arg_lead:lower()) then
      table.insert(completions, symbol)
    end
    seen[symbol] = true
  end
  
  table.sort(completions)
  return completions
end

-- Create the user command
vim.api.nvim_create_user_command('Price', fetch_crypto_price, {
  nargs = 1,
  complete = crypto_complete,
  desc = 'Fetch cryptocurrency price (e.g., :Price btc)'
})

-- Optional: Create quick commands for top cryptos
vim.api.nvim_create_user_command('PriceBTC', function() 
  fetch_crypto_price({ args = "btc" }) 
end, { desc = 'Get Bitcoin price' })

vim.api.nvim_create_user_command('PriceETH', function() 
  fetch_crypto_price({ args = "eth" }) 
end, { desc = 'Get Ethereum price' })

-- Optional: Create keymaps
vim.keymap.set('n', '<leader>pb', ':Price btc<CR>', { desc = 'Bitcoin price' })
vim.keymap.set('n', '<leader>pe', ':Price eth<CR>', { desc = 'Ethereum price' })
-- vim.keymap.set('n', '<leader>ps', ':Price sol<CR>', { desc = 'Solana price' })
-- vim.keymap.set('n', '<leader>ps', ':Price sol<CR>', { desc = 'Solana price' })

return M
