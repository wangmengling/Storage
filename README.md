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
	var storageModel:StorageModel = StorageModel(name:"sd2", eMail: 2)
	var storage:Storage = Storage()

[Select](#storage-select)
[Insert](#storage-insert)
[Update](#storage-update)
	




### <a name="storage-select"></a>Select
> Select single data

	let value:StorageModel?  =  storage.object().filters("").sorted("").value(StorageModel.self)

> Select many data

	let value:[StorageModel]  =  storage.object().filters("").sorted("").valueOfArray(StorageModel.self)
	
### <a name="storage-insert"></a>Insert
> Insert single data

	let status = storage.add(storageModel) //Add enty
	let status = storage.create(StorageModel.self, value: ["name":"wangmaoling","eMail":654321])

> Insert many data

	let value:[StorageModel]  =  storage.object().filters("").sorted("").valueOfArray(StorageModel.self)
	
### <a name="storage-update"></a>Update
>Requires inheritance protocol StorageProtocol

	let status = storage.update(storageModel)