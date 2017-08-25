# Storage
   	Storage is a mobile database that runs directly inside phones, tablets or wearables. 
   	This repository holds the source code for the iOS versions of Storage Swift 
   	
## usage
	struct StorageModel:Codable {
	    var name: String
	    var eMail: Int?
	}
	
	extension StorageModel:StorageProtocol {
	    func primaryKey() -> String {
	        return "name"
	    }
	}
	
	var storage = Storage()

[Select](#storage-select)
	




### <a name="storage-select"></a>Select
> Select single data

	let value:StorageModel?  =  storage.object().filters("").sorted("").value(StorageModel.self)
> Select many data

	let value:[StorageModel]  =  storage.object().filters("").sorted("").valueOfArray(StorageModel.self)