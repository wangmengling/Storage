# Storage[Beta]
**Environment** Ios,Swift4
###  Beta version, the current can not be used for production, there are many bugs
   	
   	Storage is a mobile database that runs directly inside phones, tablets or wearables. 
   	This repository holds the source code for the iOS versions of Storage Swift 
   	
## usage
>Will use Codable and StorageProtocol [Must use]

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

[Delete](#storage-delete)



### <a name="storage-select"></a>Select
> Select single data

	let value:StorageModel?  =  Storage.object().filters("").sorted("").value(StorageModel.self)

> Select many data

	let value:[StorageModel]  =  Storage.object().filters("").sorted("").valueOfArray(StorageModel.self)
	
### <a name="storage-insert"></a>Insert
> Insert single data

	let status = Storage.add(storageModel) //Add enty
> Insert single data , Value is [String:Any] ，Type is inherit Codable Protocol

	let status = Storage.create(StorageModel.self, value: ["name":"wangmaoling","eMail":654321])

> Insert many data
	
	let status = Storage.addArray([storageModel])
> Insert many data , Value is [[String:Any]] ，Type is inherit Codable Protocol

	let dic = [["name":"wangmaoling","eMail":123456],["name":"wangguozhong","eMail":123456]]
	let status = Storage.create(StorageModel.self, value: dic)
	
### <a name="storage-update"></a>Update
>Requires inheritance protocol StorageProtocol

	let status = Storage.update(storageModel)
	
> Update
 
	let status = Storage.update(StorageModel.self, ["name":"wangguozhongss"]).filter(["eMail":123456]).sorted("name", ascending: true).limit(1).execute()
	
### <a name="storage-delete"></a>Delete

> Delete single data

	let status = Storage.delete(storageModel)
	
> Delete many data

	let status = Storage.delete(StorageModel.self).filter(["name":"sdsd"]).sorted("name").limit(1).execute()

> Delete all data of StorageModel type
	
	let status = Storage.deleteAll(StorageModel.self)
