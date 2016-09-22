import java.rmi.Naming;

public class HelloServer {
	public static void main (String[] args) throws Exception {
		Naming.rebind("rmi://localhost/HelloWorldServer", new HelloWorldServer());
	}
}
