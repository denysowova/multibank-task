# Multibank Stock Tracker

## Features

- **Real-time Price Updates** - Live stock price streaming via WebSocket
- **Price Change Indicators** - Visual indicators for price movements (up/down/unchanged)
- **Price Flash Animation** - Price text flashes green/red on changes
- **Stock Details** - Detailed view with company descriptions
- **Pause/Resume** - Control real-time updates with play/pause functionality
- **Deep Linking** - Deeplink support (`multibank://symbol/{symbol}`)

## Architecture

The project follows **Clean Architecture** and **MVVM** pattern on the presentation layer: 

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                 │
│  ┌──────────────────────────────────────────┐   │
│  │ SwiftUI Views & ViewModels               │   │
│  │ - FeedScreen / ViewModel                 │   │
│  │ - SymbolDetailsScreen / ViewModel        │   │
│  │ - Router (Navigation)                    │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────┐
│               Domain Layer                     │
│  ┌──────────────────────────────────────────┐  │
│  │ Business Logic                           │  │
│  │ - Stock (domain model)                   │  │
│  │ - StockStreamer (stocks stream)          │  │
│  │ - StockService (orchestration)           │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────┐
│                Data Layer                      │
│  ┌──────────────────────────────────────────┐  │
│  │ Data Sources                             │  │
│  │ - StockRepository                        │  │
│  │ - StockAPI                               │  │
│  │ - WebSocketTask                          │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────┐
│                Peripherials                    │
│  ┌──────────────────────────────────────────┐  │
│  │ Networking                               │  │
│  │ - WebSocketTask                          │  │
│  │ Navigation                               │  │
│  │ - Router                                 │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
```

## Key Implementation Details

- **Timer-based batching**: Updates every 2 seconds to reduce UI churn
- **Cache management**: In-memory cache preserves stock descriptions across updates
- **Active movers**: 10 random stocks get +/-40% volatility, others +/-5%
  The large volatility is assigned to the selected stocks to demonstrate UI list resorting
- **Error handling** all networking errors are captured and displayed via alerts

## Development Notes

The project is set to compile with latest Swift 6 with strict concurrency checking.

The reactive approaches in the project were implemented with Combine, as per task required,
though it's not the best practice to mix it with the Structured Concurrency. 

Therefore, the current implementation has some concurrency safety trade-offs:  
- **WebSocketTask** and **StockServiceImpl** are marked with **@unchecked Sendable**

There is a way to fix 
- **Mutex** wrapper for StockService mutable state (cache, publishers, streamer)

### Architecture Trade-offs

- **Service enrichment**: Stock descriptions added in service layer (pragmatic) vs. repository layer (pure Clean Architecture)
- **Presentation models**: Separate UI models vs. reusing domain models

## Testing Deep Links

- The app URL schema is "multibank". The "stocks" schema required by the task is already taken by the default iOS Stocks app.
- An example: "multibank://symbol/AAPL"
