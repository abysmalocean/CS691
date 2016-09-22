import java.rmi.Naming;

public class HelloClientLocalandRemote {
	public static void main (String[] args) throws Exception {
		HelloWorldInterface helloLocal  = (HelloWorldInterface) Naming.lookup("rmi://localhost/HelloWorldServer");
		HelloWorldInterface helloRemote = (HelloWorldInterface) Naming.lookup("rmi://128.172.248.67/HelloWorldServer");
		
		String localReturn, remoteReturn;
		long startTime, endTime, estimatedTime;
		
		startTime = System.nanoTime();    
		localReturn = helloLocal.sayHello("Alberto");
		endTime = System.nanoTime();
		estimatedTime = endTime - startTime;
		System.out.println(localReturn + " in " + estimatedTime + " ns");
		
		startTime = System.nanoTime();    
		remoteReturn = helloRemote.sayHello("Alberto");
		endTime = System.nanoTime();
		estimatedTime = endTime - startTime;
		System.out.println(remoteReturn + " in " + estimatedTime + " ns");
	}
}