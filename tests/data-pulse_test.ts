import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can add new metric as contract owner",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "data-pulse",
        "add-metric",
        [
          types.ascii("Test Metric"),
          types.ascii("Test Description"),
          types.uint(100)
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectUint(1);
  },
});

Clarinet.test({
  name: "Can record and retrieve data points",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "data-pulse", 
        "add-metric",
        [
          types.ascii("Test Metric"),
          types.ascii("Test Description"), 
          types.uint(100)
        ],
        deployer.address
      ),
      Tx.contractCall(
        "data-pulse",
        "record-data-point",
        [types.uint(1), types.uint(42)],
        deployer.address
      )
    ]);

    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().expectBool(true);

    const result = chain.callReadOnlyFn(
      "data-pulse",
      "get-metric",
      [types.uint(1)],
      deployer.address
    );
    
    result.result.expectSome().expectTuple();
  },
});

Clarinet.test({
  name: "Non-owners cannot add metrics",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "data-pulse",
        "add-metric",
        [
          types.ascii("Test Metric"),
          types.ascii("Test Description"),
          types.uint(100)
        ],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectErr().expectUint(100);
  },
});
