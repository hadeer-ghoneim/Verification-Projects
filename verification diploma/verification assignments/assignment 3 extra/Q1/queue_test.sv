//===================================================
// Module: queue_test
// Description: Demonstrates SystemVerilog queue
//              operations and predefined methods
//===================================================
module queue_test;

  // Declare integer variable and queue
  int j;
  int q[$]; // queue of integers

  initial begin
    // Step 1: Initialize j = 1 and queue q = {0, 2, 5}
    j = 1;
    q = {0, 2, 5};
    $display("Initial Queue q = %p", q);

    // Step 2: Insert j at index 1
    q.insert(1, j);
    $display("After inserting j=%0d at index 1: q = %p", j, q);

    // Step 3: Delete element at index 1
    q.delete(1);
    $display("After deleting index 1: q = %p", q);

    // Step 4: Push element 7 at the front
    q.push_front(7);
    $display("After pushing 7 at the front: q = %p", q);

    // Step 5: Push element 9 at the back
    q.push_back(9);
    $display("After pushing 9 at the back: q = %p", q);

    // Step 6: Pop element from the back into j
    j = q.pop_back();
    $display("After popping from back: q = %p, j = %0d", q, j);

    // Step 7: Pop element from the front into j
    j = q.pop_front();
    $display("After popping from front: q = %p, j = %0d", q, j);

    // Step 8: Reverse the queue
    q.reverse();
    $display("After reverse: q = %p", q);

    // Step 9: Sort the queue
    q.sort();
    $display("After sort: q = %p", q);

    // Step 10: Reverse sort (rsort) the queue
    q.rsort();
    $display("After reverse sort (rsort): q = %p", q);

    // Step 11: Shuffle the queue
    q.shuffle();
    $display("After shuffle: q = %p", q);

    // Finish simulation
    $finish;
  end

endmodule
