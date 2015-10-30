{\rtf1\ansi\ansicpg1252\cocoartf1347\cocoasubrtf570
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural

\f0\fs24 \cf0 #######################\
### TRENDATRON 5000 ###\
#######################\
\
### INTRO\
https://cryptotrader.org/strategies/peKY35zY2Z2G56rLi\
by aspiramedia (https://cryptotrader.org/aspiramedia)\
\
Please PM me with any updates, feedback, bugs, suggestions, criticism etc.\
Please leave this header intact, adding your own comments in EDITOR'S COMMENTS.\
Edited bots are NOT for submission into the CryptoTrader.org Strategies section.\
###\
\
### EDITOR'S COMMENTS\
Made any edits? Why not explain here.\
###\
\
### DONATIONS\
I am releasing this as a donation based bot. I am releasing this in hope of obtaining some donations from users here.\
Please donate BTC to: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74\
###\
\
### DISCLAIMER\
As usual with all trading, only trade with what you are able to lose.\
Start small.\
I am NOT responsible for your losses if any occur.\
###\
\
### CREDITS\
The VIX and Swing indicators used here were originally by Chris Moody at TradingView.\
Trading logic is my own.\
Thanks to all the Cryptotrader.org that helped me along the way.\
###\
\
### ADVICE\
Rather than just trading with this, I strongly recommend making this bot your own.\
Use it as a learning tool.\
Edit it to trade as you like to match your strategy.\
View this as a template for a long term trend trader with added scalping.\
Backtesting is your friend. Backtest over long periods to identify strengths and weaknesses.\
###\
\
\
############\
### CODE ###\
############\
\
STOP_LOSS = askParam 'Use a Stop Loss?', false\
STOP_LOSS_PERCENTAGE = askParam 'If so, Stop Loss Percentage?', 5\
SCALP = askParam 'Use Scalping?', true\
SPLIT = askParam 'Split orders up?', false\
SPLIT_AMOUNT = askParam 'If so, split into how many?', 4\
PERIOD = askParam 'Trend reaction time (Max = 250 | Min = 50 | Default = 250 )', 250\
\
class VIX\
    constructor: (@period) ->\
        @close = []\
        @wvf = []\
        @trade = []\
        @count = 0\
\
        # INITIALIZE ARRAYS\
        for [@close.length..22]\
            @close.push 0\
        for [@wvf.length..@period]\
            @wvf.push 0\
        for [@trade.length..10]\
            @trade.push 0\
        \
    calculate: (instrument) ->\
\
        close = instrument.close[instrument.close.length-1]\
        high = instrument.high[instrument.high.length-1]\
        low = instrument.low[instrument.low.length-1]\
        \
\
        # INCREASE DATA COUNT\
        @count++\
        \
        # REMOVE OLD DATA\
        @close.pop()\
        @wvf.pop()\
        @trade.pop()\
\
        # ADD NEW DATA\
        @close.unshift(0)\
        @wvf.unshift(0)\
        @trade.unshift(0)\
\
        # CALCULATE \
        @close[0] = close\
        \
        highest = (@close.reduce (a,b) -> Math.max a, b)\
\
        @wvf[0] = ((highest - low) / (highest)) * 100\
\
        sdev = talib.STDDEV\
            inReal: @wvf\
            startIdx: 0\
            endIdx: @wvf.length-1\
            optInTimePeriod: @period\
            optInNbDev: 1\
        sdev = sdev[sdev.length-1]\
\
        midline = talib.SMA\
            inReal: @wvf\
            startIdx: 0\
            endIdx: @wvf.length-1\
            optInTimePeriod: @period\
        midline = midline[midline.length-1]\
\
        lowerband = midline - sdev\
        upperband = midline + sdev\
\
        rangehigh = (@wvf.reduce (a,b) -> Math.max a, b) * 0.85\
        rangelow = (@wvf.reduce (a,b) -> Math.min a, b) * 1.01\
\
        if @wvf[0] >= upperband or @wvf[0] >= rangehigh\
            @trade[0] = 0\
            plotMark\
                "wvf1": @wvf[0]\
        else\
            @trade[0] = 1\
            plotMark\
                "wvf2": @wvf[0]\
            \
\
        # RETURN DATA\
        result =\
            wvf: @wvf[0]\
            rangehigh: rangehigh\
            rangelow: rangelow\
            trade: @trade\
\
        return result \
\
class GANNSWING\
    constructor: (@period) ->\
        @count = 0\
        @buycount = 0\
        @sellcount = 0\
        @lowma = []\
        @highma = []\
\
        # INITIALIZE ARRAYS\
        for [@lowma.length..5]\
            @lowma.push 0\
        for [@highma.length..5]\
            @highma.push 0\
        \
    calculate: (instrument) ->        \
\
        close = instrument.close[instrument.close.length-1]\
        high = instrument.high[instrument.high.length-1]\
        low = instrument.low[instrument.low.length-1]\
\
        # REMOVE OLD DATA\
        @lowma.pop()\
        @highma.pop()\
\
        # ADD NEW DATA\
        @lowma.unshift(0)\
        @highma.unshift(0)\
\
        # CALCULATE\
        highma = talib.SMA\
            inReal: instrument.high\
            startIdx: 0\
            endIdx: instrument.high.length-1\
            optInTimePeriod: @period\
        @highma[0] = highma[highma.length-1]\
\
        lowma = talib.SMA\
            inReal: instrument.low\
            startIdx: 0\
            endIdx: instrument.low.length-1\
            optInTimePeriod: @period\
        @lowma[0] = lowma[lowma.length-1]\
\
        if close > @highma[1]\
            hld = 1\
        else if close < @lowma[1]\
            hld = -1\
        else\
            hld = 0\
\
        if hld != 0\
            @count++\
\
        if hld != 0 && @count == 1\
            hlv = hld\
            @count = 0\
        else\
            hlv = 0\
\
        if hlv == -1\
            hi = @highma[0]\
            plotMark\
                "hi": hi * 1.2\
            @sellcount++\
            @buycount = 0\
\
        if hlv == 1\
            lo = @lowma[0]\
            plotMark\
                "lo": lo / 1.2\
            @buycount++\
            @sellcount = 0\
\
        if @buycount == 3\
            tradebuy = true\
            @buycount = 0\
        else\
            tradebuy = false\
\
\
        if @sellcount == 3\
            tradesell = true\
            @sellcount = 0\
        else\
            tradesell = false\
    \
\
        # RETURN DATA\
        result =\
            tradesell: tradesell\
            tradebuy: tradebuy\
\
        return result \
\
class FUNCTIONS\
    \
    @ROUND_DOWN: (value, places) ->\
        offset = Math.pow(10, places)\
        return Math.floor(value*offset)/offset\
        \
class TRADE    \
    \
    @BUY: (instrument, amount, split, timeout) ->\
        price = instrument.price * 1.01\
\
        if split > 0\
            amount = FUNCTIONS.ROUND_DOWN((portfolio.positions[instrument.curr()].amount/split)/price, 8)\
            for [0..split]\
                buy(instrument, amount, price, timeout)\
        else\
            buy(instrument, null, price, timeout)\
        \
    @SELL: (instrument, amount, split, timeout) ->\
        price = instrument.price * 0.99\
\
        if split > 0\
            amount = FUNCTIONS.ROUND_DOWN(portfolio.positions[instrument.asset()].amount/split, 8)\
            for [0..split]\
                sell(instrument, amount, price, timeout)\
        else\
            sell(instrument, amount, price, timeout)      \
\
init: (context)->\
    \
    context.vix = new VIX(20)           # Period of stddev and midline\
    context.swing = new GANNSWING(PERIOD)  # Period of highma and lowma\
\
    # FOR FINALISE STATS\
    context.balance_curr = 0\
    context.balance_btc = 0\
    context.price = 0\
\
    # TRADING\
    if SPLIT\
        context.trade_split = SPLIT_AMOUNT\
    else\
        context.trade_split = 0\
    context.trade_timeout   = 3000\
\
    # LOGGING\
    context.TICK = 0\
\
    # WELCOME\
    info "Welcome to the Trendatron Bot."\
    if STOP_LOSS == true\
        info "You chose to use a Stop Loss, with a cutoff of " + STOP_LOSS_PERCENTAGE + " percent."\
    if SCALP == true\
        info "You chose to use scalping (default bot behaviour)"\
    if SPLIT == true\
        info "You chose to split orders up into " + SPLIT_AMOUNT + " orders."\
\
\
\
\
handle: (context, data, storage)->\
\
    instrument = data.instruments[0]\
    price = instrument.close[instrument.close.length - 1]\
    storage.lastBuyPrice ?= 0\
\
    # FOR FINALISE STATS\
    context.price = instrument.close[instrument.close.length - 1]\
    context.balance_curr = portfolio.positions[instrument.curr()].amount\
    context.balance_btc = portfolio.positions[instrument.asset()].amount\
\
    # CALLING INDICATORS\
    vix = context.vix.calculate(instrument)\
    wvf = vix.wvf\
    rangehigh = vix.rangehigh\
    rangelow = vix.rangelow\
    trade = vix.trade\
\
    swing = context.swing.calculate(instrument)\
    tradesell = swing.tradesell\
    tradebuy = swing.tradebuy\
    \
\
    # TRADING\
    if context.balance_curr/price > 0.01\
        if tradebuy == true\
            if TRADE.BUY(instrument, null, context.trade_split, context.trade_timeout)\
                storage.lastBuyPrice = price\
                storage.stop = true\
                info "Trend Buy"\
\
    if context.balance_curr/price > 0.01 && SCALP == true\
        if trade[0] == 1 && trade[1] == 1 && trade[2] == 0 && trade[3] == 0 && trade[4] == 0 && trade[5] == 0 && wvf > 8.5\
            if TRADE.BUY(instrument, null, context.trade_split, context.trade_timeout)\
                storage.lastBuyPrice = price\
                storage.stop = true\
                info "Scalp Buy"\
\
    if context.balance_btc > 0.01\
        if (tradesell == true && wvf < 2.85) or (tradebuy == true && wvf > 8.5 && trade[0] == 1 && trade[1] == 0)\
            if TRADE.SELL(instrument, null, context.trade_split, context.trade_timeout)\
                storage.lastBuyPrice = 0\
                storage.stop = false\
                info "Trend Sell"\
    \
    # STOP LOSS\
    if STOP_LOSS\
        if storage.stop == true && price < storage.lastBuyPrice * (1 - (STOP_LOSS_PERCENTAGE / 100))\
            if TRADE.SELL(instrument, null, context.trade_split, context.trade_timeout)\
                storage.lastBuyPrice = 0\
                storage.stop = false\
                debug "Stop Loss Sell"\
\
    # PLOTTING / DEBUG\
    plot\
        wvf: wvf\
        rangehigh: rangehigh\
        rangelow: rangelow\
    setPlotOptions\
        wvf: \
            secondary: true\
        rangehigh: \
            secondary: true\
        rangelow: \
            secondary: true\
        wvf1: \
            secondary: true\
            color: 'blue'\
        wvf2: \
            secondary: true\
            color: 'black'\
        lo: \
            color: 'green'\
        hi: \
            color: 'red'\
\
    # LOGGING\
\
    context.TICK++\
    if Math.round(context.TICK/24) == (context.TICK/24)\
        debug "Day " + context.TICK/24 + " | Fiat: " + Math.round(context.balance_curr*100)/100 + " | BTC: " +  Math.round(context.balance_btc*100)/100\
\
    if Math.round(context.TICK/744) == (context.TICK/744)\
        info "Thanks for using this free bot for the last month. Please consider a BTC donation to:"\
        info "1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74"\
        debug "(The bot carries on regardless of donations - don't worry. And if you have donated then thank you.)"\
    \
\
    \
finalize: (contex, data)-> \
\
    # DISPLAY FINALISE STATS\
    if context.balance_curr > 10\
        info "Final BTC Equiv: " + context.balance_curr/context.price\
    if context.balance_btc > 0.05\
        info "Final BTC Value: " + context.balance_btc}