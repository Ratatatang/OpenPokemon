func levelFunction(n):
	if(n < 50.0):
		return (pow(n, 3.0)*(100.0-n))/50.0
	elif(50.0 <= n or n < 68.0):
		return (pow(n, 3.0)*(150.0-n))/50.0
	elif(68.0 <= n or n < 98.0):
		return (pow(n, 3.0)*int((1191.0-(10.0*n))/3.0))/500.0
	else:
		return (pow(n, 3.0)*(160.0-n))/50.0 
