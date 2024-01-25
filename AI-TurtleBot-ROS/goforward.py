#!/usr/bin/env python
# A very basic TurtleBot script that moves TurtleBot forward indefinitely. Press CTRL + C to stop.  To run:
# On TurtleBot:
# roslaunch turtlebot_bringup minimal.launch
# On work station:
# python goforward.py

import rospy
from geometry_msgs.msg import Twist
from math import radians

class GoForward():
    def __init__(self):
        # initiliaze
        rospy.init_node('GoForward', anonymous=True) 

	# tell user how to stop TurtleBot
	rospy.loginfo("To stop TurtleBot CTRL + C")

        # What function to call when you ctrl + c    
        rospy.on_shutdown(self.shutdown)
        
	# Create a publisher which can "talk" to TurtleBot and tell it to move
        # Tip: You may need to change cmd_vel_mux/input/navi to /cmd_vel if you're not using TurtleBot2
        self.cmd_vel = rospy.Publisher('/cmd_vel', Twist, queue_size=10) 
     
	#TurtleBot will stop if we don't keep telling it to move.  How often should we tell it to move? 10 HZ
        r = rospy.Rate(10);

        
        move_cmd = Twist()
	
        move_cmd.linear.x = 0.5
	
	move_cmd.angular.z = radians(45);

	
        turn_cmd = Twist()
        turn_cmd.linear.x = 0
        turn_cmd.angular.z = radians(90); 

	
        move_opp = Twist()
        move_opp.linear.x = 1
	


	
        turn_again = Twist()
        turn_again.linear.x = 0
        turn_again.angular.z = radians(-90); 


	
        move_again = Twist()
	
        move_again.linear.x = 0.5
	
	move_again.angular.z = radians(-45);
	
	turn_cmd1 = Twist()
        turn_cmd1.linear.x = 0
        turn_cmd1.angular.z = radians(-90); 

	
        move_opp1 = Twist()
        move_opp1.linear.x = 1
	
	
	turn_cmd2 = Twist()
        turn_cmd2.linear.x = 0
        turn_cmd2.angular.z = radians(90); 	

	
        for x in range(0,190):
	    
            self.cmd_vel.publish(move_cmd)
	    
            r.sleep()
                        
	
	for x in range(0,10):
            self.cmd_vel.publish(turn_cmd)
            r.sleep() 
        
	
	for x in range(0,50):
            self.cmd_vel.publish(move_opp)
            r.sleep()  

	for x in range(0,10):
            self.cmd_vel.publish(turn_again)
            r.sleep() 

	for x in range(0,190):
            self.cmd_vel.publish(move_again)
            r.sleep() 

	for x in range(0,10):
            self.cmd_vel.publish(turn_cmd1)
            r.sleep() 
        
	
	for x in range(0,50):
            self.cmd_vel.publish(move_opp1)
            r.sleep()  
	for x in range(0,10):
            self.cmd_vel.publish(turn_cmd2)
            r.sleep()

    def shutdown(self):
        # stop turtlebot
        rospy.loginfo("Stop TurtleBot")
	# a default Twist has linear.x of 0 and angular.z of 0.  So it'll stop TurtleBot
        self.cmd_vel.publish(Twist())
	# sleep just makes sure TurtleBot receives the stop command prior to shutting down the script
        rospy.sleep(1)
 
if __name__ == '__main__':
    try:
        GoForward()
    except:
        rospy.loginfo("GoForward node terminated.")

