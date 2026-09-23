# Open-RMF High-Level Stress Tests

This folder contains bash scripts for high-level integration tests of Open-RMF. Each script initializes robots across different fleets (`tinyRobot`, `cleanerBotA`, `deliveryRobot`), dispatches tasks via `rmf_demos_tasks`, and verifies completion.

> [!NOTE]
> These stress tests are all based in `hotel` simulation.

## test_basic

Initializes all robots at their chargers, sends `tinyBot_1` to `lobby`, verifying that Open-RMF can plan and execute a basic navigation task seamlessly.

```mermaid
flowchart TD
    A["Init: tinyBot_1 to tinybot_charger"] --> B["Wait complete"]
    C["Init: cleanerBotA_1 to cleanerbot_charger1"] --> B
    D["Init: cleanerBotA_2 to cleanerbot_charger2"] --> B
    E["Init: deliveryBot_1 to deliverybot_charger"] --> B
    B --> F["tinyBot_1 to lobby"]
    F --> G["Wait tinyBot_1 complete"]
```

## test_cancellation

Creates a conflict by sending `deliveryBot_1` and then `tinyBot_1` to `restaurant`, followed by a task for `deliveryBot_1` to `kitchen`. Cancels `deliveryBot_1`'s first task halfway through, verifying that it immediately proceeds to `kitchen`, freeing up `restaurant` for `tinyBot_1`.

```mermaid
flowchart TD
    A["Init Phase"] --> B["deliveryBot_1 to restaurant"]
    B --> C["tinyBot_1 to restaurant overlap conflict"]
    C --> D["deliveryBot_1 follow-up to kitchen"]
    D --> E["Sleep 6s"]
    E --> F["Cancel deliveryBot_1 restaurant task"]
    F --> G["Wait tinyBot_1 complete"]
    G --> H["Verify deliveryBot_1 at kitchen"]
    H --> I["Wait deliveryBot_1 complete"]
```

## test_clean

Verifies that the `cleanerBotA_2` robot can properly execute a specialized cleaning task by dispatching it to `clean_waiting_area` and waiting for completion.

```mermaid
flowchart TD
    A["Init Phase"] --> B["cleanerBotA_2 clean task at clean_waiting_area"]
    B --> C["Wait cleanerBotA_2 complete"]
```

## test_current_waitspot

Verifies correct wait-spot behavior by dispatching `deliveryBot_1` and `tinyBot_1` to the same constrained location (`restaurant`), ensuring Open-RMF can resolve traffic logic securely.

```mermaid
flowchart TD
    A["Init Phase"] --> B["deliveryBot_1 to restaurant"]
    B --> C["tinyBot_1 to restaurant"]
    C --> D["Wait deliveryBot_1 complete"]
    D --> E["Wait tinyBot_1 complete"]
```

## test_delivery

Dispatches a delivery task between a dispenser at `kitchen` and ingestor at `L3_master_suite` for `deliveryBot_1`. Automatically checks robot location and artificially publishes the dispenser and ingestor task results to ensure the RMF integration workflow successfully runs end-to-end.

```mermaid
flowchart TD
    A["Init Phase"] --> B["dispatch_delivery for deliveryBot_1"]
    B --> C["Wait deliveryBot_1 at kitchen"]
    C --> D["Publish dispenser_results"]
    D --> E["Wait deliveryBot_1 at L3_master_suite"]
    E --> F["Publish ingestor_results"]
    F --> G["Wait deliveryBot_1 task complete"]
```

## test_door_interact

Tests physical object interactions securely by sending `deliveryBot_1` to `kitchen` and `cleanerBotA_2` to `clean_lobby`, forcing the navigation system to orchestrate opening and closing of doors safely along the routes.

```mermaid
flowchart TD
    A["Init Phase"] --> B["deliveryBot_1 to kitchen"]
    B --> C["Wait deliveryBot_1 complete"]
    C --> D["cleanerBotA_2 to clean_lobby"]
    D --> E["Wait cleanerBotA_2 complete"]
```

## test_emergency_pullover

Initializes the robots, starts a patrol to `restaurant` for `deliveryBot_1`, and triggers an emergency alarm to force pullover behaviors. Disables the alarm afterwards to ensure the robot gracefully resumes operations.

```mermaid
flowchart TD
    A["Init Phase"] --> B["deliveryBot_1 to restaurant"]
    B --> C["Sleep 10s"]
    C --> D["Publish emergency_signal is_emergency=true"]
    D --> E["Sleep 30s robots park"]
    E --> F["Verify deliveryBot_1 parked at deliverybot_charger"]
    F --> G["Publish emergency_signal is_emergency=false"]
    G --> H["Wait deliveryBot_1 complete"]
```

## test_lift_door_interact

Tests a complex, multi-modal interaction sequence by tasking `deliveryBot_1` to `L3_master_suite`, which requires seamlessly engaging first with a lift mechanism and sequentially with door modules gracefully.

```mermaid
flowchart TD
    A["Init Phase"] --> B["deliveryBot_1 to L3_master_suite"]
    B --> C["Wait deliveryBot_1 complete"]
```

## test_lift_interact

Specifically tests the interaction protocol with the simulated lift by sending `deliveryBot_1` to `L3_room1` bridging multiple floors flawlessly.

```mermaid
flowchart TD
    A["Init Phase"] --> B["deliveryBot_1 to L3_room1"]
    B --> C["Wait deliveryBot_1 complete"]
```

## test_patrol

Issues overlapping patrols for `tinyBot_1` and `deliveryBot_1` iteratively navigating across `L2_room1` and `kitchen` for 2 rounds. Verifies that bidirectional crossing does not cause permanent deadlocks.

```mermaid
flowchart TD
    A["Init Phase"] --> B["tinyBot_1 patrol L2_room1 to kitchen n=2"]
    B --> C["deliveryBot_1 patrol kitchen to L2_room1 n=2 overlap"]
    C --> D["Wait tinyBot_1 complete"]
    D --> E["Wait deliveryBot_1 complete"]
```
