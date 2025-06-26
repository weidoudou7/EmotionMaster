package com.ai.companion.service.impl;

import com.ai.companion.entity.Dynamic;
import com.ai.companion.mapper.DynamicMapper;
import com.ai.companion.service.DynamicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class DynamicServiceImpl implements DynamicService {
    
    @Autowired
    private DynamicMapper dynamicMapper;
    
    @Override
    public Dynamic createDynamic(String userUID, String content, List<String> images) {
        Dynamic dynamic = new Dynamic(userUID, content, images);
        dynamicMapper.insertDynamic(dynamic);
        return dynamic;
    }
    
    @Override
    public Dynamic getDynamicById(int id) {
        return dynamicMapper.getDynamicById(id);
    }
    
    @Override
    public List<Dynamic> getUserDynamics(String userUID) {
        return dynamicMapper.getDynamicsByUserUID(userUID);
    }
    
    @Override
    public List<Dynamic> getUserPublicDynamics(String userUID) {
        return dynamicMapper.getPublicDynamicsByUserUID(userUID);
    }
    
    @Override
    public List<Dynamic> getAllPublicDynamics() {
        return dynamicMapper.getAllPublicDynamics();
    }
    
    @Override
    public boolean updateDynamic(int id, String userUID, String content, List<String> images) {
        Dynamic existingDynamic = dynamicMapper.getDynamicById(id);
        if (existingDynamic == null || !existingDynamic.getUserUID().equals(userUID)) {
            return false;
        }
        
        existingDynamic.setContent(content);
        existingDynamic.setImages(images);
        existingDynamic.setUpdateTime(LocalDateTime.now());
        
        return dynamicMapper.updateDynamic(existingDynamic) > 0;
    }
    
    @Override
    public boolean deleteDynamic(int id, String userUID) {
        return dynamicMapper.deleteDynamic(id, userUID) > 0;
    }
    
    @Override
    public boolean likeDynamic(int id) {
        Dynamic dynamic = dynamicMapper.getDynamicById(id);
        if (dynamic == null) {
            return false;
        }
        
        dynamic.setLikeCount(dynamic.getLikeCount() + 1);
        return dynamicMapper.updateLikeCount(id, dynamic.getLikeCount()) > 0;
    }
    
    @Override
    public boolean unlikeDynamic(int id) {
        Dynamic dynamic = dynamicMapper.getDynamicById(id);
        if (dynamic == null || dynamic.getLikeCount() <= 0) {
            return false;
        }
        
        dynamic.setLikeCount(dynamic.getLikeCount() - 1);
        return dynamicMapper.updateLikeCount(id, dynamic.getLikeCount()) > 0;
    }
} 