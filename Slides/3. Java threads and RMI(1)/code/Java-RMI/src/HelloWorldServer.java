import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

public class HelloWorldServer extends UnicastRemoteObject implements HelloWorldInterface {

	private static final long serialVersionUID = 6681945041782552448L;

	public HelloWorldServer() throws RemoteException {
		super();
	}

	public String sayHello(String name) throws RemoteException {
		return "Hello " + name;
	}
}
