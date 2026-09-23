#!/bin/bash

# NOTE: Test with finishing request set to [nothing]
# Initialize robot positions
ros2 run rmf_demos_tasks dispatch_go_to_place -p tinybot_charger -F tinyRobot -R tinyBot_1 --use_sim_time
ros2 run rmf_demos_tasks dispatch_go_to_place -p cleanerbot_charger1 -F cleanerBotA -R cleanerBotA_1 --use_sim_time
ros2 run rmf_demos_tasks dispatch_go_to_place -p cleanerbot_charger2 -F cleanerBotA -R cleanerBotA_2 --use_sim_time
ros2 run rmf_demos_tasks dispatch_go_to_place -p deliverybot_charger -F deliveryRobot -R deliveryBot_1 --use_sim_time
ros2 run rmf_demos_tasks wait_for_task_complete -F tinyRobot -R tinyBot_1 --timeout 500
ros2 run rmf_demos_tasks wait_for_task_complete -F cleanerBotA -R cleanerBotA_1 --timeout 500
ros2 run rmf_demos_tasks wait_for_task_complete -F cleanerBotA -R cleanerBotA_2 --timeout 500
ros2 run rmf_demos_tasks wait_for_task_complete -F deliveryRobot -R deliveryBot_1 --timeout 500
ret=$?
if [ $ret -ne 0 ]; then
        echo "Test failed"
        exit -1
fi

# Dispatching a delivery task
RESPONSE=$(ros2 run rmf_demos_tasks dispatch_delivery -p kitchen -ph hotel_kitchen_dispenser -d L2_master_suite -dh guest_receiver -F deliveryRobot -R deliveryBot_1 --use_sim_time)
REQUEST_GUID=$(echo "$RESPONSE" | grep -o 'delivery_[0-9a-fA-F-]*' | head -1)

ros2 run rmf_demos_tasks get_robot_location -F deliveryRobot -R deliveryBot_1 -B kitchen --timeout 500
ret=$?
if [ $ret -ne 0 ]; then
        echo "Test failed"
        exit -1
fi

sleep 5
for i in {1..10}; do
    ros2 topic pub --once /dispenser_results rmf_dispenser_msgs/msg/DispenserResult "{time: {sec: $(date +%s)}, request_guid: '${REQUEST_GUID}', source_guid: 'hotel_kitchen_dispenser', status: 1}"
done

ros2 run rmf_demos_tasks get_robot_location -F deliveryRobot -R deliveryBot_1 -B L2_master_suite --timeout 500
ret=$?
if [ $ret -ne 0 ]; then
        echo "Test failed"
        exit -1
fi

sleep 5
for i in {1..10}; do
    ros2 topic pub --once /ingestor_results rmf_ingestor_msgs/msg/IngestorResult "{time: {sec: $(date +%s)}, request_guid: '${REQUEST_GUID}', source_guid: 'guest_receiver', status: 1}"
done

ros2 run rmf_demos_tasks wait_for_task_complete -F deliveryRobot -R deliveryBot_1 --timeout 500
ret=$?
if [ $ret -ne 0 ]; then
        echo "Test failed"
        exit -1
fi
