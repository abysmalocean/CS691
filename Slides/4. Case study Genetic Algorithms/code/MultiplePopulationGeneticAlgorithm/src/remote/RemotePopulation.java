package remote;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

import evolutionary.Individual;
import evolutionary.SSGA;

public class RemotePopulation extends UnicastRemoteObject implements IRemotePopulation {

	private static final long serialVersionUID = 6681945041782552448L;
	
	private SSGA localAlgorithm;

	public RemotePopulation() throws RemoteException {
		super();
	}

	@Override
	public void initializePopulation(int seed, int populationSize, int numberDimensions) throws RemoteException {
		localAlgorithm = new SSGA(seed, populationSize, numberDimensions);
		localAlgorithm.initializePopulation();
	}
	
	@Override
	public void runSSGA(int SSGAIterations) throws RemoteException {
		localAlgorithm.runSSGA(SSGAIterations);
	}

	@Override
	public Individual getBestIndividual() throws RemoteException {
		return localAlgorithm.getPopulation().get(0); // assumes population is sorted
	}

	@Override
	public void updatePopulation(Individual individual) throws RemoteException {
		localAlgorithm.updatePopulation(individual);
	}
}