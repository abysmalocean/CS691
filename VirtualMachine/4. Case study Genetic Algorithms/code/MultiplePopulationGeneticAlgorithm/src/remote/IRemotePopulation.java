package remote;
import java.rmi.Remote;
import java.rmi.RemoteException;

import evolutionary.Individual;

public interface IRemotePopulation extends Remote {
	public void initializePopulation(int seed, int populationSize, int numberDimensions) throws RemoteException;
	public void runSSGA(int SSGAIterations) throws RemoteException;
	public Individual getBestIndividual() throws RemoteException;
	public void updatePopulation(Individual individual) throws RemoteException;
}