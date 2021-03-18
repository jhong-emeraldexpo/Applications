public class EE_UtilityRelationshipType {
    public static boolean CurrentUserAccessLevel(id userId){
        User CurrentUsr = new User();
        CurrentUsr = [SELECT Id, Profile.Name FROM User WHERE Id = : userId];
        system.debug('CurrentUsr'+CurrentUsr);
        system.debug('CurrentUsr.Profile.Name'+CurrentUsr.Profile.Name);

        List<PermissionSetAssignment> userPermissionSetList = [select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :CurrentUsr.id and PermissionSet.Name = 'EE_EditAttendeeRecords'];
    
        if(CurrentUsr.Profile.Name == 'Data Migration' || CurrentUsr.Profile.Name == 'System Administrator' || CurrentUsr.Profile.Name == 'Super User'|| userPermissionSetList.size()>0 ){
            return True;
        }
        else{
            return False;
        }
            
    }
}