## Storage
   	Storage is a mobile database that runs directly inside phones, tablets or wearables. This repository holds the source code for the iOS versions of Storage Swift 
   	
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

[Select](#storage-select)
	




### <a name="storage-select"></a>Select
	var storage = Storage()
	let value:StorageModel?  =  storage.object(StorageModel.self).filters("").sorted("").value(StorageModel.self)