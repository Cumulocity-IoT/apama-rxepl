# Sample PySys testcase
# Copyright (c) 2015-2016 Software AG, Darmstadt, Germany and/or Software AG USA Inc., Reston, VA, USA, and/or its subsidiaries and/or its affiliates and/or their licensors. 
# Use, reproduction, transfer, publication or disclosure is prohibited except as specifically provided for in your License Agreement with Software AG 

from pysys.constants import *
from pysys.basetest import BaseTest
from apama.correlator import CorrelatorHelper

class PySysTest(BaseTest):

	def execute(self):
		correlator = CorrelatorHelper(self, name='correlator')
		
		correlator.start(logfile='correlator.log')
		correlator.injectCDP(filenames='RxEPL.cdp', filedir=PROJECT.TEST_SUBJECT_DIR)
		correlator.flush()
		correlator.injectEPL(filenames='testUtils.mon', filedir=PROJECT.UTILS_DIR)
		
		# Start test results receiver
		correlator.receive(filename='TestResult.evt', channels=['TestResult'], logChannels=True)

		# Inject test
		correlator.injectEPL(filenames=['test.mon'])
		
		# wait for all events to be processed
		correlator.flush()
		
		# wait for test to complete
		self.waitForSignal('TestResult.evt', expr="TestComplete", condition="==1", timeout=3)
		
	def validate(self):
		# check the main correlator log for Errors
		self.assertGrep('correlator.log', expr=' (ERROR|FATAL) ', contains=False)
		
		# Check that the test didn't fail
		self.assertGrep('TestResult.evt', expr='TestFailed', contains=False)
		