/**The MIT License (MIT)
Copyright (c) 2016 Smart Contract Solutions, Inc.
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
/**The MIT License (MIT)
Copyright (c) 2016 Smart Contract Solutions, Inc.
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
pragma solidity ^0.4.24;
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }


    function add(Role storage role, address addr) internal{
        role.bearer[addr] = true;
    }


    function remove(Role storage role, address addr) internal{
        role.bearer[addr] = false;
    }


    function check(Role storage role, address addr) internal view {
        require(has(role, addr),"BAN");
    }

    function has(Role storage role, address addr) internal view  returns (bool){
        return role.bearer[addr];
    }
}
contract RBAC {
    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address indexed operator, string role);
    event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
    function checkRole(address _operator, string _role) public view {
        roles[_role].check(_operator);
    }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
    function hasRole(address _operator, string _role) internal view returns (bool){
        return roles[_role].has(_operator);
    }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
    function addRole(address _operator, string _role) internal {
        roles[_role].add(_operator);
        emit RoleAdded(_operator, _role);
    }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
    function removeRole(address _operator, string _role) internal{
        roles[_role].remove(_operator);
        emit RoleRemoved(_operator, _role);
    }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
    modifier onlyRole(string _role){
        checkRole(msg.sender, _role);
        _;
    }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}

contract AuthorList is RBAC {
    string private constant ROLE_AUTHOR = "author";
    
    modifier onlyIfAuthor(address _operator){
        checkRole(_operator, ROLE_AUTHOR);
        _;
    }

    function addAddressToAuthor(address _operator) internal {
        addRole(_operator, ROLE_AUTHOR);
    }

    function authorlist(address _operator) internal view returns (bool) {
        return hasRole(_operator, ROLE_AUTHOR);
    }

    function addAddressesToAuthorList(address[] _operators) internal {
        for (uint256 i = 0; i < _operators.length; i++) {
            addAddressToAuthor(_operators[i]);
        }
    }
}

contract SmartPaperList {
    address[] public smartPapers;
    function createPaper(bytes32 _description, bytes32 _metaData, bytes16 _paperMD5, address[] _authors) public returns(address){
        address newPaper = new SmartPaper(_description, _metaData, _paperMD5, _authors);
        smartPapers.push(newPaper);
        return newPaper;
    }

    function getProjects() public view returns(address[]) {
        return smartPapers;
    }
}

contract SmartPaper is AuthorList{
    struct Version{
        uint versionNumber;
        bytes32 versionDescription;
        bytes32 metaData;
        bool isPublished;
        mapping (address => bool) signs;
        uint voterCount;
    }
    bytes32 private latestDescription;
    bytes32 private latestMetaData;
    bytes16 private latestPaper;
    uint public latestVersion;
    address private newAuthor; 
    uint private agreeCount;
    address[] public authors;
    mapping(address => bool) isAuthor;
    mapping(address => bool) isAgree;
    bytes16[] public md5List;
    Version[] public versions;
    mapping (bytes16 => Version) public versionMap;
    constructor (bytes32 _description, bytes32 _metaData, bytes16 _paperMD5, address[] _authors) public{
        require(_authors.length > 0, "Invalid authors list");
        authors = _authors;
        latestPaper = _paperMD5;
        md5List.push(latestPaper);
        latestMetaData = _metaData;
        latestDescription = _description;
        uint versionNumber = uint(1); 
        addAddressesToAuthorList(_authors);
        Version memory newVersion = Version({
            versionNumber: versionNumber,
            versionDescription:latestDescription,
            metaData:latestMetaData,
            isPublished:false,
            voterCount:1
        });
        versions.push(newVersion);
        versions[0].signs[msg.sender] = true;
        versionMap[latestPaper] = newVersion; 
        for(uint256 i = 0; i < _authors.length; i++){
            isAuthor[_authors[i]] = true;
            isAgree[_authors[i]] = false;
        }       
    }
    function checkIn() public onlyIfAuthor(msg.sender) payable{
        require(versions[0].signs[msg.sender] == false, "Ban");
        versions[0].signs[msg.sender] = true;
        versions[0].voterCount++;
        if(versions[0].voterCount == authors.length + 1){
            versions[0].isPublished = true;
            latestVersion = versions[0].versionNumber;
        }
        versionMap[md5List[0]] = versions[0];
    }
    function getPapers() public view returns (bytes16[]){
        return md5List;
    }
    function getAuthors() public view returns (address[]){
        return authors;
    }
    function createNewVersion(bytes32 versionDescription, bytes32 metaData, bytes16 md5) public
    onlyIfAuthor(msg.sender) payable {
        uint versionNumber = latestVersion + 1;
        Version memory newVersion = Version({
            versionNumber: versionNumber,
            versionDescription:versionDescription,
            metaData:metaData,
            isPublished:false,
            voterCount:1
        });
        md5List.push(md5);
        versions.push(newVersion);
        versionMap[md5] = newVersion;
    }
    function addNewAuthor(address _newAuthor) public onlyIfAuthor(msg.sender) payable{
        require(newAuthor==address(0), "Ban");
        newAuthor = _newAuthor;
        agreeCount = 0;
    }
    function approveNew(address _newAuthor) public onlyIfAuthor(msg.sender) payable{
        require(newAuthor == _newAuthor,"BAN");
        agreeCount++;
        isAgree[msg.sender] = true;
        if(agreeCount == authors.length){
            addAddressToAuthor(newAuthor);
            authors.push(newAuthor);
            isAuthor[newAuthor] = true;
            newAuthor = address(0);
            agreeCount = 0;
            for(uint i = 0; i<authors.length; i++){
                isAgree[authors[i]] = false;
            }
        }
    }
    function approveVersion(uint _versionNumber, bytes16 md5)  public onlyIfAuthor(msg.sender) payable{
        Version storage version = versions[_versionNumber-1];
        require(!version.signs[msg.sender], "BAN");
        version.signs[msg.sender] = true;
        version.voterCount++;
        if(version.voterCount==authors.length + 1){
            version.isPublished = true;
            latestVersion = version.versionNumber;
            latestDescription = version.versionDescription;
            latestMetaData = version.metaData;
            latestPaper = md5;
            versionMap[md5] = version;
            require(versionMap[md5].versionNumber == versions[_versionNumber-1].versionNumber, "BAN");
            require(versionMap[md5].versionDescription == versions[_versionNumber-1].versionDescription, "BAN");
            require(versionMap[md5].isPublished == versions[_versionNumber-1].isPublished, "BAN");
            require(versionMap[md5].metaData == versions[_versionNumber-1].metaData, "BAN");
            require(versionMap[md5].voterCount == versions[_versionNumber-1].voterCount, "BAN");
            require(latestVersion == versions[_versionNumber-1].versionNumber, "BAN");
        }
        versionMap[md5] = version;
    }
    function getSummary() public view returns (bytes32, bytes32, bytes16, uint, uint, bool, bool, bool){
        if(newAuthor != address(0)){
            return (
                latestDescription,
                latestMetaData,
                latestPaper,
                latestVersion,
                versions.length,
                isAuthor[msg.sender],
                isAgree[msg.sender],
                true
            );
        }else{
            return (
                latestDescription,
                latestMetaData,
                latestPaper,
                latestVersion,
                versions.length,
                isAuthor[msg.sender],
                isAgree[msg.sender],
                false
            );
        }
    }
    function getVersion(uint _versionNumber) public view returns(bytes32,bytes32,bool,uint,address,bytes16,bool){
        require(_versionNumber >= 0, "BAN");
        address versionAddress = address(this);
        return(
            versions[_versionNumber].versionDescription,
            versions[_versionNumber].metaData,
            versions[_versionNumber].isPublished,
            versions[_versionNumber].voterCount,
            versionAddress,
            md5List[_versionNumber],
            versions[_versionNumber].signs[msg.sender]
        );
    }
}  
