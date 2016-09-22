package experiments;
import java.rmi.Naming;

import remote.RemotePopulation;

public class RunRemotePopulationServer {
	public static void main (String[] args) throws Exception {
		Naming.rebind("rmi://localhost/RemotePopulation" + args[0], new RemotePopulation());
	}
}