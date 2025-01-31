# DataPulse
Real-time blockchain data visualization tools and metrics tracking system built on Stacks.

## Features
- Track and store key blockchain metrics
- Record historical data points
- Query and visualize data trends
- Configurable data collection intervals
- Value validation with customizable min/max bounds per metric

## Usage
The contract provides functions to:
- Record new data points for different metrics
- Query historical data 
- Calculate trends and moving averages
- Set data collection parameters
- Validate data points against metric-specific bounds

## Getting Started
1. Deploy the contract 
2. Configure metrics with collection intervals and value bounds
3. Start recording data points (values must be within specified bounds)
4. Query visualizations through read-only functions

## Value Validation
Each metric can now be configured with minimum and maximum allowed values:
- Values outside these bounds will be rejected
- Helps maintain data quality and prevent outliers
- Bounds are set during metric creation
