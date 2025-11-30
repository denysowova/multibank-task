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
- **Active movers**: 10 random stocks get +/-40% volatility, others +/-5%. The large volatility is assigned to the selected stocks to demonstrate UI list resorting
- **Error handling** all networking errors are captured and displayed via alerts

## Development Notes

The project compiles with Swift 6 strict concurrency checking enabled.

The reactive approaches were implemented with Combine as per task requirements, though mixing it with Structured Concurrency introduces some trade-offs.

### Concurrency Safety Considerations

**StockServiceImpl** is marked with **@unchecked Sendable** because:

1. **Actor approach would require async interface**: Making the service an actor forces all exposed methods async, resulting in awkward signatures like `func stocks() async -> AnyPublisher<[Stock], StockError>`. This mixes execution models: you'd `await` to get a publisher, then subscribe to it. Semantically, async/await is for suspension-based code, while publishers are reactive streams. Combining both creates an unnatural API where you suspend to obtain a reactive stream.

2. **@unchecked Sendable is safe in this context**: The compiler requires Sendable conformance for objects crossing concurrency domains. Marking it as Sendable makes the compiler complain about mutable state (`streamer`, `cache`, etc.). However, in our implementation all mutations occur on MainActor (Timer on `.main` queue, Combine sinks use `.receive(on: DispatchQueue.main)`)

3. **Alternative: Full thread safety**: The mutable state can be protected with locking mechanisms (Mutex). See the `safe-service` branch for an implementation using `Mutex<StockState>` to wrap all mutable properties, achieving true Sendable conformance without `@unchecked`. 

### Architecture Trade-offs

- **Service enrichment**: Stock descriptions added in service layer (pragmatic) vs. repository layer (pure Clean Architecture)
- **Presentation models**: Separate UI models vs. reusing domain models

## Testing Deep Links

- The app URL schema is "multibank". The "stocks" schema required by the task is already taken by the default iOS Stocks app.
- An example: "multibank://symbol/AAPL"
