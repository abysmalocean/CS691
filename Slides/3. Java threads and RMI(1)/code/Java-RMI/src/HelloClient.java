import java.rmi.Naming;

public class HelloClient {
	public static void main (String[] args) throws Exception {
		HelloWorldInterface hello = (HelloWorldInterface) Naming.lookup("rmi://localhost/HelloWorldServer");
		System.out.println(hello.sayHello("Alberto"));
	}
}