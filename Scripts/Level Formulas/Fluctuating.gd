func levelFunction(n):
	if(n < 15.0):
		return (pow(n, 3.0)*(int((n+1.0)/3.0)+24.0))/50.0
	elif(15.0 <= n or n < 36.0):
		return (pow(n, 3.0)*(n+14.0))/50.0
	else:
		return (pow(n, 3.0)*(int(n/2.0)+32.0))/50.0
